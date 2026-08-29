package iibs.actualites.config;

import org.springframework.context.annotation.*;
import org.springframework.data.mongodb.*;

@Configuration
public class MongoTransactionConfig {

    @Bean
    public MongoTransactionManager gestionnaireTransactions(MongoDatabaseFactory factory) {
        return new MongoTransactionManager(factory);
    }
}
