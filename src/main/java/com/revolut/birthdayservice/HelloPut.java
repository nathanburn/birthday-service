package com.revolut.birthdayservice;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.time.temporal.ChronoUnit;

import com.revolut.birthdayservice.exception.DateOfBirthInFutureException;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class HelloPut {
    @NotBlank(message = "Date of Birth must not be null or blank")
    @Pattern(regexp = "^[0-9]{4}-[0-9]{2}-[0-9]{2}$", message = "Date of Birth must be in the format YYYY-MM-DD")
    private String dateOfBirth;

    public HelloPut() { }

    public HelloPut (String dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(String dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    /**
     * Get date of birth as a LocalDate, validate format and that it is a date in the past.
     * @return
     * @throws DateTimeParseException
     * @throws DateOfBirthInFutureException
     */
    public LocalDate getDateOfBirthAsLocalDate() throws DateTimeParseException, DateOfBirthInFutureException {
        return this.getDateOfBirthAsLocalDate(LocalDate.now());
    }

    /**
     * Get date of birth as a LocalDate, validate format and that it is a date in the past.
     * @param comparisonDate
     * @return
     * @throws DateTimeParseException
     * @throws DateOfBirthInFutureException
     */
    public LocalDate getDateOfBirthAsLocalDate(LocalDate comparisonDate) throws DateTimeParseException, DateOfBirthInFutureException {
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("uuuu-MM-dd").withResolverStyle(ResolverStyle.STRICT);
        LocalDate dateOfBirth = LocalDate.parse(this.dateOfBirth, dateTimeFormatter);
        long days = ChronoUnit.DAYS.between(comparisonDate, dateOfBirth);
        if (days >= 0) {
            throw new DateOfBirthInFutureException("YYYY-MM-DD must be a date before the today date.");
        }
        return dateOfBirth;
    }
}
