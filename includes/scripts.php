<?php
function comarquage_scripts() {

	// JS Enqueue
	wp_register_script('google-mapjs', 'https://maps.googleapis.com/maps/api/js?language=fr', '', '3.0', true );
	wp_enqueue_script( 'google-mapjs' );
	
	// CSS enqueue
	if ( get_option('comarquage_global_css_enable') ) {
		wp_register_style( 'emendo-comarquage', COMARQUAGE_URI .'assets/css/comarquage.css',null,'0.0.1');
		wp_enqueue_style( 'emendo-comarquage' );
	}
	
	// Fontawesome for Icon
	wp_register_style( 'font-awesome', '//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css',null,'4.3.0');
	wp_enqueue_style( 'font-awesome' );
	
}
add_action( 'wp_enqueue_scripts', 'comarquage_scripts' );