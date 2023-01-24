package com.revolut.birthdayservice;

import com.revolut.birthdayservice.exception.ResourceNotFoundException;
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
     * @param helloPut dateOfBirth must be a date before the today date.
     * @return
     */
    @PutMapping("/hello/{username}")
    public ResponseEntity<Void> hello(@PathVariable String username, @RequestBody HelloPut helloPut) {
        // TODO: handle 'update'
        // TODO: handle regex and the now datetime validation
        User user = new User(username, helloPut.getDateOfBirth());
        userRepository.save(user);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    /**
     * Returns hello birthday message for the given user
     * @param username must contain only letters
     * @return
     */
    @GetMapping("/hello/{username}")
    public ResponseEntity<HelloGet> hello(@PathVariable String username) {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new ResourceNotFoundException("User does not exist with username: " + username));
        // TODO: handle variation of messaging based on current datetime
        HelloGet helloGet = new HelloGet(String.format("Hello, %s %s!", user.getUsername(), user.getDateOfBirth()));
        return ResponseEntity.ok(helloGet);
    }

}