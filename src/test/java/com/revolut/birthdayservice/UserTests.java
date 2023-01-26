package com.revolut.birthdayservice;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.util.Set;

import org.junit.jupiter.api.Test;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;

public class UserTests {

    private LocalDate today = LocalDate.of(2023, 2, 9);
    private LocalDate birthday = LocalDate.of(1986, 2, 9);
    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    public void testUserValidation_withValidValues_noViolations() {
        // arrange
        User user = new User("joeb", birthday);
        // assert
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertTrue(violations.isEmpty());
    }

    @Test
    public void testUsernameNotBlankValidation_withEmptyString_raisesViolations() {
        // arrange
        User user = new User("", birthday);
        // assert
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertEquals(2, violations.size());
    }

    @Test
    public void testUsernamePatternValidation_withNumbers_raisesViolations() {
        // arrange
        User user = new User("abc123", birthday);
        // assert
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        assertEquals(1, violations.size());
    }

    @Test
    public void testGetBirthdayGreeting_withTenDayPositiveDifference_returnsTen() {
        // arrange
        User user = new User("joeb", LocalDate.of(1986, 2, 19));
        // act
        long numberOfDays = user.getNumberOfDaysUntilBirthday(today);
        String birthdayGreeting = user.getBirthdayGreeting(today);
        // assert
        assertEquals((long) 10, numberOfDays);
        assertEquals("Hello, joeb! Your birthday is in 10 day(s)", birthdayGreeting);
    }

    @Test
    public void testGetBirthdayGreeting_withTenDayNegativeDifference_returnsThreeHundredFiftyFive() {
        // arrange
        User user = new User("janes", LocalDate.of(1986, 1, 30));
        // act
        long numberOfDays = user.getNumberOfDaysUntilBirthday(today);
        String birthdayGreeting = user.getBirthdayGreeting(today);
        // assert
        assertEquals((long) 355, numberOfDays);
        assertEquals("Hello, janes! Your birthday is in 355 day(s)", birthdayGreeting);
    }

    @Test
    public void testGetBirthdayGreeting_withSameDate_returnsZero() {
        // arrange
        User user = new User("johnd", birthday);
        // act
        long numberOfDays = user.getNumberOfDaysUntilBirthday(today);
        String birthdayGreeting = user.getBirthdayGreeting(today);
        // assert
        assertEquals((long) 0, numberOfDays);
        assertEquals("Hello, johnd! Happy birthday!", birthdayGreeting);
    }
}
