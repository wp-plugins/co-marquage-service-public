<?php
/*
comarquage
License : emendo.fr
Date : 09/12/2014
Author : Sebastien BOURSIER / Christel RENARD / EMENDO
Version : 0.1
*/

class comarquage {
	
	var $comarquage_cat;
	var $cat;
	var $options;
	
	var $xml_dir;
	var $xml_base_dir; 
	
	var $pivot_mode;
	
	var $ref; 
	
	public static $comarquage_pivots_url = "http://lecomarquage.service-public.fr/donnees_locales_v2/all/";
	
	public static $comarquage_xml_part_zip = "http://lecomarquage.service-public.fr/vdd/2.3/part/zip/vosdroits-latest.zip";
	public static $comarquage_xml_pro_zip = "http://lecomarquage.service-public.fr/vdd/2.3/pro/zip/vosdroitspro-latest.zip";
	public static $comarquage_xml_asso_zip = "http://lecomarquage.service-public.fr/vdd/2.3/asso/zip/vosdroitsasso-latest.zip";

	
	function __construct($categorie = null) {
	
		if(empty($categorie)) $categorie = 'part';
		$this->comarquage_cat = $categorie; // Recupère la categorie du comarquage à afficher
		
		// init
		$this->LoadEnv();
	}
	
	// Init Env
	public function LoadEnv() {
		
		// Les options du plugins
		$this->options = EMENDO_Comarquage_Options::get_all_options();
		
		// Pivot mode enable ?
		$this->pivot_mode = ($this->options->comarquage_global_pivot_enable) ? "pivot" : "web"; // local ou generique
		
		// Long name array
		$this->cat = array ( "part" => "particuliers", "pro" => "professionnels", "asso" => "associations" );
		
		// Base DIR for XML
		$upload_dir = wp_upload_dir();
		$this->xml_base_dir = $upload_dir['basedir'] . '/comarquage/'; // Repertoire ou sont stockés les XML dans la zone d'upload de wordpress
		
		// Define the DIR for XML (Part, pro or asso)
		$this->xml_dir = $upload_dir['basedir'] . '/comarquage/' . $this->comarquage_cat . '/' . $this->options->comarquage_update_time[$this->comarquage_cat] . '/';
		
	}
	
	// Donwload des zip
	public function Update_with_zip($url,$cat) {
		
		require_once(ABSPATH . "wp-admin" . '/includes/file.php');
		$begin_time = time();
		
		if( !empty($url) ) {
			
			// Telechargement du fichier zip
			$tmp = download_url( $url );
		    $file_array = array(
		        'name' => basename( $url ),
		        'tmp_name' => $tmp
		    );
		    if ( is_wp_error( $tmp ) ) {
		        @unlink( $file_array[ 'tmp_name' ] );
		        return $tmp;
		    }
		    
		    // Destination
		    $destination_path = $this->xml_base_dir . $cat . "/" . $begin_time . "/";
		    if (!file_exists($destination_path)) mkdir($destination_path, 0777, true); // création du repertoire s'il n'existe pas

		    // UNZIP
		    WP_Filesystem(); // Load filesystem env
			$unzipfile = unzip_file( $file_array[ 'tmp_name' ], $destination_path);
			
			if ( !is_wp_error($unzipfile) ) {
				
				// Update the Plugin Option
				$update_time = get_option( 'comarquage_update_time');
				$update_time[$cat] = $begin_time;
				update_option( 'comarquage_update_time', $update_time);
				
				// Update the Environnement
				$this->LoadEnv();
			
			} else print_r($unzipfile);
			@unlink( $file_array[ 'tmp_name' ] ); // Unlink
			
			// -------- Suppression des anciennes versions
			$files = scandir( $this->xml_base_dir . $cat, 1);
			
			// On depile les chemins . et ..
			array_pop($files);
			array_pop($files);

			// On depile les trois derniers telechargement
			array_shift($files);
			array_shift($files);
			array_shift($files);
			
			// Delete files and directories;
			foreach ($files as $rep ) {
				$dir = $this->xml_base_dir . $cat . "/" . $rep . "/";
				array_map('unlink', glob($dir . "*.xml"));
				if(is_dir($dir)) rmdir($dir);
			}
		}
	}
	
	// Recupere le timestamp d'un fichier distant
	public function get_zip_date($url) {
		
		$curl = curl_init($url);
		curl_setopt($curl, CURLOPT_NOBODY, true); // Pas de récuperation du BODY, uniquement les headers
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); // On ne veut pas le telecharger
		curl_setopt($curl, CURLOPT_FILETIME, true);	// On essaye de recupérer la date du fichier
		
		// On recupère les infos
		$result = curl_exec($curl);
		if ($result === false) die (curl_error($curl)); 
		
		// Le timestamp
		$timestamp = curl_getinfo($curl, CURLINFO_FILETIME);
		if ($timestamp != -1) { //otherwise unknown
		    // echo date("Y-m-d H:i:s", $timestamp); //etc
		    return $timestamp;
		} else return false;
	}

	// MAJ des XML
	public function update_xml($force) {
		 if ( ($this->get_zip_date(self::$comarquage_xml_part_zip)) > $this->options->comarquage_update_time['part'] || $force) $this->Update_with_zip(self::$comarquage_xml_part_zip, 'part');
		 if ( ($this->get_zip_date(self::$comarquage_xml_pro_zip)) > $this->options->comarquage_update_time['pro'] || $force) $this->Update_with_zip(self::$comarquage_xml_pro_zip, 'pro');
		 if ( ($this->get_zip_date(self::$comarquage_xml_asso_zip)) > $this->options->comarquage_update_time['asso'] || $force) $this->Update_with_zip(self::$comarquage_xml_asso_zip, 'asso');
	}

	// Affiche le comarquage 
	function display() {
				
		libxml_disable_entity_loader(false);
		// La première fois on charge les XML
		if ( empty($this->options->comarquage_update_time[$this->comarquage_cat]) ) { 
			$this->Update_with_zip(self::$comarquage_xml_part_zip, $this->comarquage_cat);
		}

		// Search / Header
		if($this->comarquage_header()) return;
	  	
	  	// url du fichier xml (fiche distante / theme local)
	  	$xml_file = empty($_GET["xml"]) ? $this->comarquage_cat . ".xml" : $_GET["xml"] . ".xml";
	  	$xml_path = empty($_GET["xml"]) ? COMARQUAGE_DIR . "assets/themes/" . $xml_file : $this->xml_dir . $xml_file;
	  	
	  	// xsl en local
	  	$xsl_file = empty($_GET["xml"]) ? "Home.xsl" : "spMainNoeud.xsl";
	  	$xsl_path = COMARQUAGE_DIR . "assets/xsl/" . $xsl_file;
	  	
	  	// ref de la fiche
	  	$this->ref = substr($xml_file,0, -4);
		
		// ------------- Construct the xml object
		$xslDoc = new DOMDocument();
		$xslDoc->load($xsl_path);
		
		$xmlDoc = new DOMDocument();
		$xmlDoc->load($xml_path);
		
		$proc = new XSLTProcessor();
		$proc->importStylesheet($xslDoc);
		
		
		// -------------- Define XSL Value
		
		// Link for category page
		$proc->setParameter(null,"CATEGORIE", $this->comarquage_cat); // Set Category
		$proc->setParameter(null,"CATEGORIE_NOM", $this->cat[$this->comarquage_cat]); // Set Category
		
		$proc->setParameter(null,"HYPERLIEN_PART", get_permalink());
		$proc->setParameter(null,"HYPERLIEN_ASSO", get_permalink());
		$proc->setParameter(null,"HYPERLIEN_PRO", get_permalink());

		$proc->setParameter(null,"AFF_SOMMAIRE", 'false'); // Do not display sommaire
		$proc->setParameter(null,"AFF_DATE", 'false'); // Do not display date
		$proc->setParameter(null,"AFF_PICTOS", 'false'); // Display the picto
		
		$proc->setParameter(null,"IMAGES", COMARQUAGE_URI . "assets/images/"); // Images folder
		$proc->setParameter(null,"AFF_RESSOURCES", 'false');
		$proc->setParameter(null,"AFF_BARRE_THEME", 'false');
		$proc->setParameter(null,"AFF_IMAGES", 'true');
		
		//$proc->setParameter(null,"DONNEES", $comarquage_xml_uri); // URL of XML directory
		$proc->setParameter(null,"XML_COURANT", $this->xml_dir);
		
		// Local pivot
		$proc->setParameter(null,"MODE_PIVOT", $this->pivot_mode);  // Pivot Mode : pivot / web   (for local or generic contact)
		$proc->setParameter(null,"PIVOTS_DONNEES", self::$comarquage_pivots_url);
		$proc->setParameter(null,"PIVOT_DEP", $this->options->comarquage_global_departement);
		$proc->setParameter(null,"PIVOT_INSEE", $this->options->comarquage_global_code_insee);
		
		// ---------------- Get and Display the result
		$content = $proc->transformToXML($xmlDoc);
		
		echo $content;
		
		// Footer
		$this->comarquage_footer();
	}
	
	
	// Affiche la recherche du comarquage
	function xml_attribute($object, $attribute)
	{
	    if(isset($object[$attribute]))
	        return (string) $object[$attribute];
	}
	
	function clean_search($string) {
		
		// Replace ' and -
		$string = str_replace(array("'", "-", '\\')," ",$string);

		// Replace stopword
		$stopword = array( ' l ', ' le ', ' la ', ' les ', ' ou ', ' et ', ' un ', ' à ', ' en ', ' par ', ' sa ', ' son ' , ' ses ', ' aux ', ' dans ', ' sans ', ' du ', ' d ', ' de ', ' des ', '\\');
		$string = str_replace($stopword, " ", $string);
		
		// Replace accent
		$a = array('À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'ß', 'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'ÿ', 'Ā', 'ā', 'Ă', 'ă', 'Ą', 'ą', 'Ć', 'ć', 'Ĉ', 'ĉ', 'Ċ', 'ċ', 'Č', 'č', 'Ď', 'ď', 'Đ', 'đ', 'Ē', 'ē', 'Ĕ', 'ĕ', 'Ė', 'ė', 'Ę', 'ę', 'Ě', 'ě', 'Ĝ', 'ĝ', 'Ğ', 'ğ', 'Ġ', 'ġ', 'Ģ', 'ģ', 'Ĥ', 'ĥ', 'Ħ', 'ħ', 'Ĩ', 'ĩ', 'Ī', 'ī', 'Ĭ', 'ĭ', 'Į', 'į', 'İ', 'ı', 'Ĳ', 'ĳ', 'Ĵ', 'ĵ', 'Ķ', 'ķ', 'Ĺ', 'ĺ', 'Ļ', 'ļ', 'Ľ', 'ľ', 'Ŀ', 'ŀ', 'Ł', 'ł', 'Ń', 'ń', 'Ņ', 'ņ', 'Ň', 'ň', 'ŉ', 'Ō', 'ō', 'Ŏ', 'ŏ', 'Ő', 'ő', 'Œ', 'œ', 'Ŕ', 'ŕ', 'Ŗ', 'ŗ', 'Ř', 'ř', 'Ś', 'ś', 'Ŝ', 'ŝ', 'Ş', 'ş', 'Š', 'š', 'Ţ', 'ţ', 'Ť', 'ť', 'Ŧ', 'ŧ', 'Ũ', 'ũ', 'Ū', 'ū', 'Ŭ', 'ŭ', 'Ů', 'ů', 'Ű', 'ű', 'Ų', 'ų', 'Ŵ', 'ŵ', 'Ŷ', 'ŷ', 'Ÿ', 'Ź', 'ź', 'Ż', 'ż', 'Ž', 'ž', 'ſ', 'ƒ', 'Ơ', 'ơ', 'Ư', 'ư', 'Ǎ', 'ǎ', 'Ǐ', 'ǐ', 'Ǒ', 'ǒ', 'Ǔ', 'ǔ', 'Ǖ', 'ǖ', 'Ǘ', 'ǘ', 'Ǚ', 'ǚ', 'Ǜ', 'ǜ', 'Ǻ', 'ǻ', 'Ǽ', 'ǽ', 'Ǿ', 'ǿ', 'Ά', 'ά', 'Έ', 'έ', 'Ό', 'ό', 'Ώ', 'ώ', 'Ί', 'ί', 'ϊ', 'ΐ', 'Ύ', 'ύ', 'ϋ', 'ΰ', 'Ή', 'ή');
		$b = array('A', 'A', 'A', 'A', 'A', 'A', 'AE', 'C', 'E', 'E', 'E', 'E', 'I', 'I', 'I', 'I', 'D', 'N', 'O', 'O', 'O', 'O', 'O', 'O', 'U', 'U', 'U', 'U', 'Y', 's', 'a', 'a', 'a', 'a', 'a', 'a', 'ae', 'c', 'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i', 'n', 'o', 'o', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u', 'y', 'y', 'A', 'a', 'A', 'a', 'A', 'a', 'C', 'c', 'C', 'c', 'C', 'c', 'C', 'c', 'D', 'd', 'D', 'd', 'E', 'e', 'E', 'e', 'E', 'e', 'E', 'e', 'E', 'e', 'G', 'g', 'G', 'g', 'G', 'g', 'G', 'g', 'H', 'h', 'H', 'h', 'I', 'i', 'I', 'i', 'I', 'i', 'I', 'i', 'I', 'i', 'IJ', 'ij', 'J', 'j', 'K', 'k', 'L', 'l', 'L', 'l', 'L', 'l', 'L', 'l', 'l', 'l', 'N', 'n', 'N', 'n', 'N', 'n', 'n', 'O', 'o', 'O', 'o', 'O', 'o', 'OE', 'oe', 'R', 'r', 'R', 'r', 'R', 'r', 'S', 's', 'S', 's', 'S', 's', 'S', 's', 'T', 't', 'T', 't', 'T', 't', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'W', 'w', 'Y', 'y', 'Y', 'Z', 'z', 'Z', 'z', 'Z', 'z', 's', 'f', 'O', 'o', 'U', 'u', 'A', 'a', 'I', 'i', 'O', 'o', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'A', 'a', 'AE', 'ae', 'O', 'o', 'Α', 'α', 'Ε', 'ε', 'Ο', 'ο', 'Ω', 'ω', 'Ι', 'ι', 'ι', 'ι', 'Υ', 'υ', 'υ', 'υ', 'Η', 'η');
		$string = str_replace($a, $b, $string);
		
		$string = strtolower($string);
		
		return preg_replace('/[^A-Za-z0-9 \-]/', '', $string); // Removes special chars.
	}
	
	public function comarquage_header() { ?>
		
		<div id="co-bar" >
		<a href="./" class="co-home"><i class="fa fa-home"></i></a>
		<form id="co-search" action="<?php the_permalink(); ?>" name="cosearch" method="POST">
			<input type="hidden" name="action" value="cosearch">
			<input type="text" name="search"  class="co-searchinput" placeholder="Recherche">
			<input type="submit" value="Ok" class="co-searchbtn">
		</form>
		
		<a href="http://mon.service-public.fr" target="_blank" class="monsp">mon.service-public.fr</a>
		</div>
		
		<?php
		if(!empty($_POST['search'])) {
			
			$search = $this->clean_search($_POST['search']);
			$xml = simplexml_load_file($this->xml_dir . "arborescence.xml");
			
			// La recherche dans les fichiers arborescence
			$nodes = $xml->xpath("//Item[@fichier='true' and contains(@type,'information')]/Titre/parent::*");
			
			echo "<p class='search-title'>R&eacute;sultat(s) de votre recherche : <b>" . $search . "</b></p>";
			
			// On cherche
			$results = array();
			foreach($nodes as $node)
			{ 
				$titre = (string) $node->Titre;
				$titre = $this->clean_search($titre);

				if (strpos($titre, $search) !== false) {
					// Si on trouve, on enregistre
					$id = $this->xml_attribute($node,'ID');
					$results[$id] = (string) $node->Titre;
				}
			}
			$results = array_unique($results);
			
			// On affiche		
			if(!empty($results)) {
				
				echo "<ul class='search-result'>";
				foreach($results as $id => $titre) {
					
					$titre = str_ireplace($search, '<span class="colorsearch">' . $search . '</span>', $titre); // On colorie le terme trouvé ?>
					<li><a href="<?php the_permalink(); ?>?xml=<?php echo $id; ?>"><?php echo $titre; ?></a></li>
					
					<?php
				} 
				echo "</ul>";
			} else echo "Aucun r&eacute;sultat trouv&eacute;";
			
			return true; // On arrete l'affichage du reste
		}
	
	}
	
	// Affiche le pied de page du comarquage
	public function comarquage_footer() {
		?>
		
		<script type="text/javascript">
		<?php include(COMARQUAGE_DIR . '/assets/js/comarquage.js'); ?>
		</script>
		
		
		<footer class="comarquage-footer">
			<div class="mentions">
			<p>&copy; <a href="http://www.dila.premier-ministre.gouv.fr" target="_blank">Direction de l'information l&eacute;gale et administrative</a>
			<?php if(!empty($_GET["xml"])) { ?>
			- Ref : <a href="http://vosdroits.service-public.fr/<?php echo $this->cat[$this->comarquage_cat]; ?>/<?php echo $this->ref; ?>.xhtml" target="_blank"><?php echo $this->ref; ?></a>
			<?php } ?>
			</p>
			<?php if($this->options->comarquage_global_poweredby) { ?>
				<p> r&eacute;alisation : <a href="http://www.emendo.fr" target="_blank" title="agence de communication">emendo.fr</a></p>
			<?php } ?>
			</div>
			<a  class="logo-sp" href="http://www.service-public.fr/" target="_blank"><img src="<?php echo COMARQUAGE_URI . "assets/images/service-public.png"; ?>"></a>
		</footer>
		<?php
	}
	
			
}