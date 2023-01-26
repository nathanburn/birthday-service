package com.revolut.birthdayservice.exception;

public class DateOfBirthInFutureException extends Exception{
    public DateOfBirthInFutureException(String message){
        super(message);
    }
}
