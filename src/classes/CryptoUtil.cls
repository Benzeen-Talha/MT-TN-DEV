/**
* @description: Utilities class for Apex Crypto related functions
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 08/07/16  M.Barbarelli        Created class
*/
public class CryptoUtil {
    
    public static Blob key = Blob.valueOf('VgF96ST2IhdQ7kF-bZXhis^jopnE*vtX'); 
    
    public static Blob Decrypt(Blob encryptedBlob, String cipherType){
        
        Blob decryptedBlob = Crypto.decryptWithManagedIV(cipherType, key, encryptedBlob);
        
        return decryptedBlob;         
    }
    
}