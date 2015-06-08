<?php
/*
EMENDO_Comarquage
License : emendo.fr
Date : 15/01/2015
Author : EMENDO
Version : 0.1
*/

// OPTIONS Class for the comarquage

class EMENDO_Comarquage_Options {

	function __construct() {
	
		// Register actions
		add_action('admin_init', array(&$this, 'register_comarquage_setting') );
		add_action('admin_menu', array(&$this, 'add_menu'));
	
    }
    
    // Define the list and the default options value
    public static function get_default_options() {

         $options = array(
         	// --- Core setting
         	'comarquage_global_css_enable' =>  1,
         	'comarquage_global_poweredby' =>  1,
         	'comarquage_global_pivot_enable' =>  0,
         	'comarquage_global_departement' =>  '91',
         	'comarquage_global_code_insee' =>  '91386',
         	'comarquage_update_time' =>  array()
        );
        
        return $options;
    }
    
    
    // Return option and their actual value
	public static function get_all_options() {
		
		$DefaultOptions = EMENDO_Comarquage_Options::get_default_options(); // Get Default options list
		
		// Get options list
		$options = new stdClass();
    	foreach( $DefaultOptions as $option_name => $default_value ) {
			$options->$option_name = get_option($option_name) ? get_option($option_name) : 0 ; // By Default 0 for uncheck checkbox
		}
		
		return $options;
	}
    
    
    // Setup Default value on first activation
    function setup_default_options() {
    	
    	$DefaultOptions = EMENDO_Comarquage_Options::get_default_options(); // Get Default options list
		
		// Setup Default value on the first time
    	foreach( $DefaultOptions as $option_name => $default_value ) {
    		// delete_option($option_name); // Only use this for test
			if(!get_option($option_name)) add_option($option_name, $default_value);
		}
		
    }
    
   	// Register setting for setting page 
    function register_comarquage_setting() {
    
    	$options = $this->get_default_options();
   
    	foreach( $options as $option_name => $default_value ) {
			register_setting('emendo-comarquage', $option_name);
		}
		
	} 
	
    
    // Add Menu
    public function add_menu()
    {
	    if(is_plugin_active('emendo-updater/emendo-updater.php')) {
		    
	    	// Add setting page under emendo-menu
	    	add_submenu_page( 'emendo-menu', 'Co-Marquage Reglages', 'Co-Marquage', 'manage_options', 'emendo-comarquage-options', array(&$this, 'comarquage_settings_page'));
		
		} else {
			
			// Add setting page under settings
			add_options_page( 'comarquage-setting', 'Co-Marquage','manage_options', 'comarquage-options', array(&$this, 'comarquage_settings_page'));
			
		}
    
    }
    
    // Setting Page
    function comarquage_settings_page() {  
	
		if(!current_user_can('manage_options')) wp_die(__('You do not have sufficient permissions to access this page.'));
		require_once(COMARQUAGE_ADMIN . "settings.php");
	}
   	  
}