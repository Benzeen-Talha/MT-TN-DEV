/**
* @description: Utilities class for Address related functions 
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 08/06/16  M.Barbarelli        Created class
*/
public class AddressUtil {
    
    public static string CountryLookup(string country){
        Map<String,String> CountryMap = new Map<String,String>();
        CountryMap.put('TANZANIA','Tanzania, United Republic of');
		CountryMap.put('VENEZUELA','Venezuela, Bolivarian Republic of');
        CountryMap.put('VIRGIN ISLANDS, U.S.','Virgin Islands, British');
        CountryMap.put('ÅLAND ISLANDS','Aland Islands');
        CountryMap.put('BOLIVIA','Bolivia, Plurinational State of');

        if (CountryMap.containsKey(country.toUpperCase())){
            country = CountryMap.get(country.toUpperCase());
        }
        
        return country;
    }
    
    public static string US_StateLookup(string state){
        
        Map<String,String> US_StateMap = new Map<String,String>();
        US_StateMap.put('AL','Alabama');
        US_StateMap.put('AK','Alaska');
        US_StateMap.put('AZ','Arizona');
        US_StateMap.put('AR','Arkansas');        
        US_StateMap.put('CA','California');
        US_StateMap.put('CO','Colorado');
        US_StateMap.put('CT','Connecticut');
        US_StateMap.put('DE','Delaware'); 
        US_StateMap.put('FL','Florida');
        US_StateMap.put('GA','Georgia');
        US_StateMap.put('HI','Hawaii');
        US_StateMap.put('ID','Idaho');
        US_StateMap.put('IL','Illinois');
        US_StateMap.put('IN','Indiana');        
        US_StateMap.put('IA','Iowa');
        US_StateMap.put('KS','Kansas');
        US_StateMap.put('KY','Kentucky');
        US_StateMap.put('LA','Louisiana'); 
        US_StateMap.put('ME','Maine');
        US_StateMap.put('MD','Maryland');
        US_StateMap.put('MA','Massachusetts');
        US_StateMap.put('MI','Michigan');
        US_StateMap.put('MN','Minnesota');
        US_StateMap.put('MS','Mississippi');        
        US_StateMap.put('MO','Missouri');
        US_StateMap.put('MT','Montana');
        US_StateMap.put('NE','Nebraska');
        US_StateMap.put('NV','Nevada'); 
        US_StateMap.put('NH','New Hampshire');
        US_StateMap.put('NJ','New Jersey');
        US_StateMap.put('NM','New Mexico');
        US_StateMap.put('NY','New York');
        US_StateMap.put('NC','North Carolina');
        US_StateMap.put('ND','North Dakota');        
        US_StateMap.put('OH','Ohio');
        US_StateMap.put('OK','Oklahoma');
        US_StateMap.put('OR','Oregon');
        US_StateMap.put('PA','Pennsylvania'); 
        US_StateMap.put('RI','Rhode Island');
        US_StateMap.put('SC','South Carolina');
        US_StateMap.put('SD','South Dakota');
        US_StateMap.put('TN','Tennessee');
        US_StateMap.put('TX','Texas');
        US_StateMap.put('UT','Utah');        
        US_StateMap.put('VT','Vermont');
        US_StateMap.put('VA','Virginia');
        US_StateMap.put('WA','Washington');
        US_StateMap.put('WV','West Virginia'); 
        US_StateMap.put('WI','Wisconsin');
        US_StateMap.put('WY','Wyoming');   
        
        if (US_StateMap.containsKey(state.toUpperCase())){
            state = US_StateMap.get(state.toUpperCase());
        }
        return state;
    }
    
}