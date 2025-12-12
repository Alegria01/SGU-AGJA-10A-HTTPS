package mx.edu.utez.server.utils;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;

@Configuration
public class DBConnection {
    @Value("${db.host}")
    private String host;

    @Value("${db.port}")
    private String port;

    @Value("${db.name}")
    private String name;

    @Value("${db.user}")
    private String username;

    @Value("${db.pass}")
    private String password;

    @Bean
    public DataSource getConnection() {
        DriverManagerDataSource conf = new DriverManagerDataSource();
        conf.setDriverClassName("com.mysql.cj.jdbc.Driver");
        conf.setUrl("jdbc:mysql://" + host + ":" + port + "/" + name);
        conf.setUsername(username);
        conf.setPassword(password);

        return conf;
    }
}