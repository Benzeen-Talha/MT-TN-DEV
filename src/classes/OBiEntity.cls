public class OBiEntity {
    public String taxregistrationno;
    public String companyregistrationno;
    public Address registeredaddress;
    public Address tradingaddress;
    public String sharecapital;
    public String typeofcompany;
    public String nocourtofregistration;
    public String townofregistration;
    public String chairman;
    public String chairmanofboard;
    public String liablecompany;
    public String businessstyle;
    public String profession;
    public String taxregime;
    public String liquidator;
    public Address liquidatoraddress;
    public String earlypaymentdisc;
    public String latepaypenalty;
    public String permitno;
    public Datetime periodstartdate;
    public String certificationno;
    public Boolean hascertificationno;
    public List<String> directors;
    public List<String> executivedirectors;
    public String name;
    public Integer entityid;
    public String salesforceid;

    public class Address {
        public String line1;
        public String line2;
        public String line3;
        public String city;
        public String state;
        public String zipcode;
        public String countrycode;
    }

    
    public static OBiEntity parse(String json) {
        return (OBiEntity) System.JSON.deserialize(json, OBiEntity.class);
    }
   
}