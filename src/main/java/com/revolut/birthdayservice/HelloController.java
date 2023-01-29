package com.revolut.birthdayservice;

import com.revolut.birthdayservice.exception.DateOfBirthInFutureException;
import com.revolut.birthdayservice.exception.ResourceNotFoundException;

import java.time.Instant;
import java.time.format.DateTimeParseException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @Autowired
    UserRepository userRepository;

    /**
     * Saves/updates the given user’s name and date of birth in the database.
     * @param username must contain only letters
     * @param helloPut dateOfBirth format "YYYY-MM-DD" and must be a date before the today date.
     * @return
     * @throws DateTimeParseException
     * @throws DateOfBirthInFutureException
     */
    @PutMapping("/hello/{username}")
    public ResponseEntity<String> hello(@PathVariable String username, @RequestBody HelloPut helloPut) throws DateTimeParseException, DateOfBirthInFutureException {
        User user;
        try {
            user = userRepository.findByUsername(username)
                .orElse(new User(username, helloPut.getDateOfBirthAsLocalDate()));
            user.setUpdatedTimestamp(Instant.now());
        } catch(DateTimeParseException | DateOfBirthInFutureException exception) {
            return ResponseEntity.badRequest().body(exception.getMessage());
        }
        userRepository.save(user);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    /**
     * Returns hello birthday message for the given user
     * @param username must contain only letters
     * @return Http response, with birthday greeting message if successful
     */
    @GetMapping("/hello/{username}")
    public ResponseEntity<HelloGet> hello(@PathVariable String username) {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new ResourceNotFoundException("User does not exist with username: " + username));
        HelloGet helloGet = new HelloGet(user.getBirthdayGreeting());
        return ResponseEntity.ok(helloGet);
    }

}