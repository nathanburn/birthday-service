package com.revolut.birthdayservice;

import java.time.Instant;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;
import java.util.Objects;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;

import com.fasterxml.jackson.annotation.JsonIgnore;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * Represents a User with a username and date of birth.
 * Interactions are tracked through the version, created and updated fields.
 * Supports future retiring and reuse of usernames with unique generated id field.
 */
@Entity
@Table(name = "users") // required as 'user' is a reserved keyword in SQL
public class User {

    private @Id @GeneratedValue Long id;

    private String username;
    private String dateOfBirth;

    @CreationTimestamp
    private Instant createdTimestamp;
    @UpdateTimestamp
    private Instant updatedTimestamp;

    private @Version @JsonIgnore Long version;

    // Default constructor required by JPA
    private User() {}

    public User(
            String username,
            String dateOfBirth
    ) {
        this.username = username;
        this.dateOfBirth = dateOfBirth;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User service = (User) o;
        return Objects.equals(id, service.id) &&
                Objects.equals(username, service.username) &&
                Objects.equals(dateOfBirth, service.dateOfBirth) &&
                Objects.equals(version, service.version);
    }

    @Override
    public int hashCode() {

        return Objects.hash(id, username, dateOfBirth, version);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(String dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public Long getVersion() {
        return version;
    }

    public void setVersion(Long version) {
        this.version = version;
    }

    public String getCreatedTimestamp() {
        return DateTimeFormatter.ofLocalizedDateTime( FormatStyle.MEDIUM ).withZone(ZoneId.from(ZoneOffset.UTC)).format(createdTimestamp);
    }

    public String getUpdatedTimestamp() {
        return DateTimeFormatter.ofLocalizedDateTime( FormatStyle.MEDIUM ).withZone(ZoneId.from(ZoneOffset.UTC)).format(updatedTimestamp);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", dateOfBirth='" + dateOfBirth + '\'' +
                ", version=" + version +
                '}';
    }
}
