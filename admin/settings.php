<?php if(!current_user_can('manage_options')) wp_die(__('You do not have sufficient permissions to access this page.')); ?>

<div class="wrap" id="emendo-slider-page">
    
    <h2>EMENDO CO-MARQUAGE : R&eacute;glages</h2>
	<br>
	<?php $options = EMENDO_Comarquage_Options::get_all_options(); ?>
    
    <form method="post" action="options.php">
    
        <?php @settings_fields('emendo-comarquage'); ?>
                
	        <table class="form-table">
		        <tr valign="top">
		            <th scope="row">Plugin options</th>
		            <td>
			            <fieldset>
			            	<label for="comarquage_global_css_enable"><input name="comarquage_global_css_enable" type="checkbox" id="comarquage_global_css_enable" value="1" <?php checked( 1, get_option( 'comarquage_global_css_enable' ) ); ?>> Utiliser le CSS du plugin</label><br>
			            	<label for="comarquage_global_poweredby"><input name="comarquage_global_poweredby" type="checkbox" id="comarquage_global_poweredby" value="1" <?php checked( 1, get_option( 'comarquage_global_poweredby' ) ); ?>> Afficher le lien "réalisation : emendo.fr" (Ce n'est pas une obligation mais c'est sympa)</label><br>
			            </fieldset>
		            </td>
		        </tr>
		        
		        <tr valign="top">
		            <th scope="row">Informations locales</th>
		            <td>
			            <fieldset>
			            	<hr>
			            	<label for="comarquage_global_pivot_enable"><input name="comarquage_global_pivot_enable" type="checkbox" id="comarquage_global_pivot_enable" value="1" <?php checked( 1, get_option( 'comarquage_global_pivot_enable' ) ); ?>> Activer les informations locales (adresses des &eacute;tablissements locaux) </label><br>
			            	
			            	<label for="comarquage_global_departement">D&eacute;partement :
			               	<input name="comarquage_global_departement" type="text" id="comarquage_global_departement" value="<?php echo $options->comarquage_global_departement; ?>" class="regular-text"> (ex: 91) </label> <br>
			            	
			            	<label for="comarquage_global_code_insee">Code INSEE :
			               	<input name="comarquage_global_code_insee" type="text" id="comarquage_global_code_insee" value="<?php echo $options->comarquage_global_code_insee; ?>" class="regular-text"> (ex: 77491) <br/>
			               	<a href="http://www.insee.fr/fr/methodes/nomenclatures/cog/" target="_blank"> Conna&icirc;tre mon code INSEE </a>
			               	</label><br>
			            </fieldset>
		            </td>
		        </tr>
	        </table>
	              
        <?php @submit_button(); ?>

    </form>
    
    <?php if(isset($_POST['action']) && $_POST['action'] == 'comarquage-xml-update') {
    		emendo_comarquage::comarquage_xml_update(true); // force the update
    }
    ?>
    
    
    <p> Vérifier les coordonnées d'une Mairie : <a href="http://lannuaire.service-public.fr" target="_blank"> annuaire de l'administration </a><br>   (pour modifier les coordonnées cliquer sur : Faire une remarque sur cette page)</p><br>
    <p> <u> Derni&egrave;re mise à jour des fichiers XML du comarquage : </u><br>
    particulier : <?php if(!empty($options->comarquage_update_time['part'])) echo date('Y-m-d H:i', $options->comarquage_update_time['part']); ?><br>
    professionnel : <?php if(!empty($options->comarquage_update_time['pro']))echo date('Y-m-d H:i', $options->comarquage_update_time['pro']); ?><br>
    association : <?php if(!empty($options->comarquage_update_time['asso']))echo date('Y-m-d H:i', $options->comarquage_update_time['asso']); ?></p>


    <form method="post">
    	<input type="hidden" name="action" value="comarquage-xml-update">
    	<input type="submit" class="button" value="Mettre à jour les XMLs de service-public.fr">
    </form>



    <br><br><p> réalisation : <a href="http://www.emendo.fr" target="_blank">emendo.fr</a></p>

</div>