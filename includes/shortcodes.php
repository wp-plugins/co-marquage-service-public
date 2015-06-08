<?php
function comarquage( $atts ) {

	 // ------------ Extract shortcode atts
	extract(shortcode_atts(array(
		'category' 	=> 'part'
	), $atts));

  	ob_start();
  	
	$comarquage = new comarquage($category);
  	?>
	
	<div class="comarquage">
		<?php $comarquage->display(); ?>
	</div>
	
	<?php
	return ob_get_clean();
	
}
add_shortcode('comarquage', 'comarquage');