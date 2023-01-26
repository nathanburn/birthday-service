package com.revolut.birthdayservice;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Set;

import org.junit.jupiter.api.Test;

import com.revolut.birthdayservice.exception.DateOfBirthInFutureException;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;

public class HelloPutTests {

    private LocalDate today = LocalDate.of(2023, 2, 9);
    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    public void testHelloPutValidation_withValidValues_noViolations() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("1986-01-30");
        // act
        LocalDate dateOfBirth = helloPut.getDateOfBirthAsLocalDate();
        // assert
        Set<ConstraintViolation<HelloPut>> violations = validator.validate(helloPut);
        assertTrue(violations.isEmpty());
        assertEquals(LocalDate.of(1986, 01, 30), dateOfBirth);
    }

    @Test
    public void testHelloPutValidation_withEmptyDateOfBirth_raisesViolations() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("");
        // assert
        Set<ConstraintViolation<HelloPut>> violations = validator.validate(helloPut);
        assertEquals(2, violations.size());
    }

    @Test
    public void testHelloPutValidation_withInvalidDateOfBirthFormat_raisesViolation() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("00AB-01-30");
        // assert
        Set<ConstraintViolation<HelloPut>> violations = validator.validate(helloPut);
        assertEquals(1, violations.size());
    }

    @Test
    public void testHelloPutValidation_withInvalidDateOfBirth_throwsDateTimeParseException() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("0000-00-00");
        // assert
        assertThrows(DateTimeParseException.class, () -> {
            // act
            helloPut.getDateOfBirthAsLocalDate();
        });
    }

    @Test
    public void testHelloPutValidation_withInvalidOutOfBoundsDateOfBirth_throwsDateTimeParseException() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("1986-02-30");
        // assert
        assertThrows(DateTimeParseException.class, () -> {
            // act
            helloPut.getDateOfBirthAsLocalDate();
        });
    }

    @Test
    public void testHelloPutValidation_withSameDayDateOfBirth_throwsException() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("2023-02-09");
        // assert
        Throwable exception = assertThrows(DateOfBirthInFutureException.class, () -> {
            // act
            helloPut.getDateOfBirthAsLocalDate(today);
        });
        assertEquals("YYYY-MM-DD must be a date before the today date.", exception.getMessage());
    }

    @Test
    public void testHelloPutValidation_withFutureDateOfBirth_throwsException() throws DateTimeParseException, DateOfBirthInFutureException {
        // arrange
        HelloPut helloPut = new HelloPut("2024-02-09");
        // assert
        Throwable exception = assertThrows(DateOfBirthInFutureException.class, () -> {
            // act
            helloPut.getDateOfBirthAsLocalDate(today);
        });
        assertEquals("YYYY-MM-DD must be a date before the today date.", exception.getMessage());
    }
}
