package com.revolut.birthdayservice;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.FormatStyle;
import java.time.temporal.ChronoUnit;
import java.util.Objects;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

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

    @Id
    @GeneratedValue 
    private Long id;
    
    @NotBlank(message = "Username must not be null or blank")
    @Pattern(regexp = "^[a-z]{1,}$", message = "Username must contain only lower case characters")
    private String username;

    private LocalDate dateOfBirth;

    @CreationTimestamp
    private Instant createdTimestamp;
    @UpdateTimestamp
    private Instant updatedTimestamp;

    private @Version @JsonIgnore Long version;

    public User() { }

    public User(
            String username,
            LocalDate dateOfBirth
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

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
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

    /**
     * Get a username greeting e.g. "Hello, <username>!"
     * @return A greeting
     */
    public String getUsernameGreeting() {
        return String.format("Hello, %s!", this.username);
    }

    /**
     * Get the number of days from now until the user's birthday  
     * @return A number of days
     */
    public long getNumberOfDaysUntilBirthday() {
        return this.getNumberOfDaysUntilBirthday(LocalDate.now());
    }

    /**
     * Get the number of days from a comparison date until the user's birthday 
     * @param comparisonDate
     * @return A number of days
     */
    public long getNumberOfDaysUntilBirthday(LocalDate comparisonDate) {
        if (comparisonDate == null) {
            comparisonDate = LocalDate.now();
        }
        LocalDate nextBithdayDate = this.dateOfBirth.withYear(comparisonDate.getYear());

        // add 1 year, if birthday has already been
        if (nextBithdayDate.isBefore(comparisonDate)) {
            nextBithdayDate = nextBithdayDate.plusYears(1);
        }

        return ChronoUnit.DAYS.between(comparisonDate, nextBithdayDate);
    }

    /**
     * Get a birthday greeting message either: 
     * "Hello, <username>! Your birthday is in N day(s)" or "Hello, <username>! Happy birthday!"
     * @return
     */
    public String getBirthdayGreeting() {
        return this.getBirthdayGreeting(LocalDate.now());
    }

    /**
     * Get a birthday greeting message either: 
     * "Hello, <username>! Your birthday is in N day(s)" or "Hello, <username>! Happy birthday!"
     * @param comparisonDate
     * @return
     */
    public String getBirthdayGreeting(LocalDate comparisonDate) {
        long numberOfDays = this.getNumberOfDaysUntilBirthday(comparisonDate);
        String birthdayGreeting = String.format("Your birthday is in %s day(s)", Long.toString(numberOfDays));
        if (numberOfDays == 0) {
            birthdayGreeting = "Happy birthday!";
        }
        return this.getUsernameGreeting() + " " + birthdayGreeting;
    }
}
