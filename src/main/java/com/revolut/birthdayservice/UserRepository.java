package com.revolut.birthdayservice;

import java.util.Optional;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "users", path = "users")
public interface UserRepository extends ListCrudRepository<User, Long> {
    Optional<User> findByUsername(@Param("username") String username);
}
