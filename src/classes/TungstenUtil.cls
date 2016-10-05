/**
* @description: Generic utilities class for helper functions
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 20/06/16  T.Sotiraki        Created class
*/
public with sharing class TungstenUtil {
	

	/**
	 * [GetStringValue Method to return string value of input]
	 * @param  str [Input String]
	 * @return     [Result String]
	 */
	public static string GetStringValue(String str){
        return (str == null ) ? '' : str; 
    }

    /**
	 * [GetStringValue Method to return string value of input]
	 * @param  str [Input String]
	 * @return     [Result String]
	 */
	public static Integer GetIntegerValue(Integer i){
        return (i == null ) ? 0 : i; 
    }


}