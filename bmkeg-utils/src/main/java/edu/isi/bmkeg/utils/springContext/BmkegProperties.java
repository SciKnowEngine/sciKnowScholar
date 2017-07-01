package edu.isi.bmkeg.utils.springContext;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Map;
import java.util.Properties;

/**
 * This class reads the bmkeg.properties file and puts the entries as
 * fields in this class. This allows us to use these property values from 
 * within java applications simply by instantiating the object or by calling 
 * the static methods or from Spring by using the following fragment
 * 
 * 	<bean id="propertyPlaceholderConfigurer"
 * 		class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
 * 		<property name="locations">
 * 			<list>
 * 				<value>#{evaluationContext.lookupVariable('homedir')}/bmkeg.properties</value>
 * 			</list>
 * 		</property>
 * 	</bean>
 * 	<bean id="bmkegProperties" class="edu.isi.bmkeg.utils.springContext.BmkegProperties">
 *		<property name="homeDirectory" value="#{evaluationContext.lookupVariable('homedir')}"/>
 * 		<property name="dbUrl" value="${bmkeg.dbUrl}"/>
 * 		<property name="dbUser" value="${bmkeg.dbUser}"/>	
 * 		<property name="dbPassword" value="${bmkeg.dbPassword}"/>	
 * 		... 
 * </bean>
 *  
 */
public class BmkegProperties {

	public static final String PROP_DBURL = "bmkeg.dbUrl";
	public static final String PROP_DBUSER = "bmkeg.dbUser";
	public static final String PROP_DBPASSWD = "bmkeg.dbPassword";
	public static final String PROP_DBDRIVER = "bmkeg.dbDriver";
	public static final String PROP_HOMEDIR = "bmkeg.homeDirectory";
	public static final String PROP_WORKINGDIR = "bmkeg.workingDirectory";
	public static final String PROP_PERSISTENCEUNIT = "bmkeg.persistenceUnitName";
	
	private String dbUrl;
	private String dbUser;
	private String dbPassword;
	private String dbDriver;
	private String homeDirectory;
	private String workingDirectory;
	private String persistenceUnitName;
	
	public static String readDbUrl(boolean isTest) throws IOException  {
		BmkegProperties bmkegProperties = new BmkegProperties(isTest);
		return bmkegProperties.getDbUrl();
	}
	
	public static String readDbUser(boolean isTest) throws IOException {
		BmkegProperties bmkegProperties = new BmkegProperties(isTest);
		return bmkegProperties.getDbUser();
	}	

	public static String readDbPassword(boolean isTest) throws IOException {
		BmkegProperties bmkegProperties = new BmkegProperties(isTest);
		return bmkegProperties.getDbPassword();
	}
	
	public static String readHomeDirectory(boolean isTest) throws IOException {
		BmkegProperties bmkegProperties = new BmkegProperties(isTest);
		return bmkegProperties.getHomeDirectory();
	}
	
	public static String readWorkingDirectory(boolean isTest) throws IOException {
		BmkegProperties bmkegProperties = new BmkegProperties(isTest);
		return bmkegProperties.getWorkingDirectory();
	}

	public static String readPersistenceUnitName(boolean isTest) throws IOException  {
		BmkegProperties bmkegProperties = new BmkegProperties(isTest);
		return bmkegProperties.getPersistenceUnitName();
	}

	/**
	 * This is the default constructor that is needed for Spring
	 */
	public BmkegProperties() {}

	/**
	 * A modified constructor for nonSpring use, this is looking in 
	 * Spring-like places for your properties file. 
	 * 1. Your home directory: ~/bmkeg
	 * 2. environment variable: BMKEG_PROPERTIESFILE
	 */
	public BmkegProperties(boolean isTest) throws IOException {
		
		Properties properties = new Properties();
		
		Map<String, String> env = System.getenv();
		String homeDir = System.getProperty("user.home");
		
		String fileName = "/bmkeg/bmkeg.properties";
		if( isTest )
			fileName = "/bmkeg/bmkegtest.properties";
		
		File propFile = new File(homeDir + fileName);
		
		if( propFile.exists() ) {

			properties.load(new FileInputStream(propFile));			

		} else if (env.containsKey("BMKEG_PROPERTIESFILE")){

			String propFileEnv = env.get("BMKEG_PROPERTIESFILE");
			propFile = new File(propFileEnv + fileName);
			if( propFile.exists() )
				properties.load(new FileInputStream(propFile));
			else 
				throw new IOException(propFile.getPath() + "does not exist.");
			
		} else {

			throw new IOException("Properties file not specified");
			
		}
					
	    this.setDbPassword((String) properties.get(PROP_DBPASSWD));
	    this.setDbUrl((String) properties.get(PROP_DBURL));
	    this.setDbUser((String) properties.get(PROP_DBUSER));
	    this.setDbDriver((String) properties.get(PROP_DBDRIVER));
	    this.setPersistenceUnitName((String) properties.get(PROP_PERSISTENCEUNIT));

	    String fileSeparator = System.getProperty("file.separator",".");
	    String homeDirectoryAddress = (String) properties.get(PROP_HOMEDIR);
		if( homeDirectoryAddress == null || !homeDirectoryAddress.endsWith(fileSeparator))
			homeDirectoryAddress += fileSeparator;

		this.setHomeDirectory(homeDirectoryAddress);

		this.setWorkingDirectory((String) properties.get(PROP_WORKINGDIR));
		
	}

	/**
	 * A modified constructor for nonSpring use, this is looking in 
	 * Spring-like places for your properties file. 
	 * 1. Your home directory: ~/bmkeg
	 * 2. environment variable: BMKEG_PROPERTIESFILE
	 */
	public BmkegProperties(File propFile) throws IOException {
		
		Properties properties = new Properties();

		if( propFile.exists() ) {

			properties.load(new FileInputStream(propFile));			

		} else {

			throw new IOException("Properties file not specified");
			
		}
					
	    this.setDbPassword((String) properties.get(PROP_DBPASSWD));
	    this.setDbUrl((String) properties.get(PROP_DBURL));
	    this.setDbUser((String) properties.get(PROP_DBUSER));
	    this.setDbDriver((String) properties.get(PROP_DBDRIVER));
	    this.setPersistenceUnitName((String) properties.get(PROP_PERSISTENCEUNIT));

	    String fileSeparator = System.getProperty("file.separator",".");
	    String homeDirectoryAddress = (String) properties.get(PROP_HOMEDIR);
		if( homeDirectoryAddress == null || !homeDirectoryAddress.endsWith(fileSeparator))
			homeDirectoryAddress += fileSeparator;

		this.setHomeDirectory(homeDirectoryAddress);

		this.setWorkingDirectory((String) properties.get(PROP_WORKINGDIR));
		
	}
	
	public void setDbUrl(String dbUrl) {
		this.dbUrl = dbUrl;
	}

	public String getDbUrl() {
		return dbUrl;
	}

	public void setDbUser(String dbUser) {
		this.dbUser = dbUser;
	}

	public String getDbUser() {
		return dbUser;
	}

	public void setDbPassword(String dbPassword) {
		this.dbPassword = dbPassword;
	}

	public String getDbPassword() {
		return dbPassword;
	}

	public void setHomeDirectory(String workingDirectory) {
		this.homeDirectory = workingDirectory;
	}

	public String getHomeDirectory() {
		return homeDirectory;
	}

	public void setPersistenceUnitName(String persistenceUnitName) {
		this.persistenceUnitName = persistenceUnitName;
	}

	public String getPersistenceUnitName() {
		return persistenceUnitName;
	}

	public void setDbDriver(String dbDriver) {
		this.dbDriver = dbDriver;
	}

	public String getDbDriver() {
		return dbDriver;
	}

	public String getWorkingDirectory() {
		return workingDirectory;
	}

	public void setWorkingDirectory(String workingDirectory) {
		this.workingDirectory = workingDirectory;
	}

	
}
