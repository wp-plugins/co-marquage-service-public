<?php
/*
Plugin Name: Comarquage service-public.fr
Plugin URI: http://www.emendo.fr
Description: Mairies et Collectivit&eacute;s uniquement : Comarquage avec service-public.fr. shortcode : [comarquage category="part / pro / asso"]
Version: 0.3.7
Author: EMENDO
Author URI: http://www.emendo.fr
Requires at least: 3.9
Tested up to: 4.2
License: GPL v3

EMENDO Repo Plugin Name: emendo-comarquage

@package Comarquage
@category Core
@author EMENDO
*/

if ( ! defined( 'ABSPATH' ) ) exit; // Exit if accessed directly

/* -------------------------------------------------------------------------------------------------------------- 

			MAIN CLASS - PAGE COMARQUAGE
			
----------------------------------------------------------------------------------------------------------------- */
if ( !class_exists( 'emendo_comarquage' ) ) {

	class emendo_comarquage {
		
		// ------------------------------------ Constructor
		function __construct() {
				
			// Start a PHP session, if not yet started
			if ( ! session_id() ) session_start();
	
			add_action( 'plugins_loaded', array( &$this, 'constants' ), 1 ); // Set Constants
			add_action( 'plugins_loaded', array( &$this, 'includes' ), 2); // Load Functions
			add_action( 'plugins_loaded', array( &$this, 'admin_init' ), 3 ); // Load Admin
			
			add_action( 'init', array( &$this, 'init' ), 0 );
			
			add_action( 'comarquage_daily_xml_update', array( &$this, 'comarquage_xml_update'), 10, false);
			
			register_activation_hook(__FILE__, array('emendo_comarquage', 'activate'));  // Activate the plugin
			register_deactivation_hook(__FILE__, array('emendo_comarquage', 'desactivate'));
			
			// Load Options
			if ( ! class_exists( 'EMENDO_Comarquage_Options' ) ) {
				require_once 'admin/class-options.php';
				new EMENDO_Comarquage_Options;
			}
			
			// Load Class Photo
			if ( ! class_exists( 'comarquage' ) ) {
				require_once 'includes/class-comarquage.php';
			}
			
		}
		
		// ------------------------------------ Constants
		function constants() {
			define( 'COMARQUAGE_VERSION', '0.1' ); // Plugin Version
			define( 'COMARQUAGE_DIR', trailingslashit( plugin_dir_path( __FILE__ ) ) ); // Plugin Directory
			define( 'COMARQUAGE_URI', trailingslashit( plugin_dir_url( __FILE__ ) ) ); // Plugin URL
			define( 'COMARQUAGE_INCLUDES', COMARQUAGE_DIR . trailingslashit( 'includes' ) ); // Path to include dir
			define( 'COMARQUAGE_ADMIN', COMARQUAGE_DIR . trailingslashit( 'admin' ) ); // Path to admin dir
		}

		// ------------------------------------ Activate / Desactivate the plugin
		public static function activate() {
			
			EMENDO_Comarquage_Options::setup_default_options();
				
			wp_schedule_event( time(), 'daily', 'comarquage_daily_xml_update' );	// Scheduled XML Update
		}
		
		public static function desactivate() {
			wp_clear_scheduled_hook( 'comarquage_daily_xml_update' );
		}
		
		// Daily update
		public function comarquage_xml_update($force =  false) {
		
			if ( ! class_exists( 'comarquage' ) ) {
				require_once 'includes/class-comarquage.php';
			}
			$comarquage = new comarquage(null);
			$comarquage->update_xml($force);
		}

		// ------------------------------------ Include
		function includes() {
			require_once( COMARQUAGE_INCLUDES . 'shortcodes.php' ); // Load shortcodes
		}
		
		// ------------------------------------ INIT
		function init() {
			require_once( COMARQUAGE_INCLUDES . 'scripts.php' ); // Load custom post definition
			
		}
		
		// ------------------------------------ ADMIN Init
		public function admin_init() {

		}
	}

	// Init the class
	if(class_exists('emendo_comarquage')) new emendo_comarquage();

}