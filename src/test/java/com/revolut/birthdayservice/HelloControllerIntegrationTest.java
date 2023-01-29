package com.revolut.birthdayservice;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;

import java.time.LocalDate;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import com.fasterxml.jackson.databind.ObjectMapper;

@ExtendWith(SpringExtension.class)
@WebMvcTest(HelloController.class)
public class HelloControllerIntegrationTest {

    @Autowired
    MockMvc mockMvc;

    @MockBean
    UserRepository userRepository;

    @Autowired
    ObjectMapper objectMapper;

    @Test
    public void testGet_withNonExistentUsername_returnsNotFound() throws Exception 
    {
        mockMvc.perform(MockMvcRequestBuilders
                .get("/hello/johnd"))
        .andDo(MockMvcResultHandlers.print())
        .andExpect(MockMvcResultMatchers.status().isNotFound());
    }

    @Test
    public void testPut_withValidUsernameAndDateOfBirth_returnsNoContent() throws Exception 
    {
        mockMvc.perform(MockMvcRequestBuilders
                .put("/hello/johnd")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(new HelloPut("1986-01-30"))))
        .andDo(MockMvcResultHandlers.print())
        .andExpect(MockMvcResultMatchers.status().isNoContent());
    }

    @Test
    public void testGet_withValidUsernameAndDateOfBirth_returnsOk() throws Exception 
    {
        Optional<User> user = Optional.of(new User("johnd", LocalDate.of(1986, 2, 9)));
        given(userRepository.findByUsername(any())).willReturn(user);

        mockMvc.perform(MockMvcRequestBuilders
                .get("/hello/johnd"))
        .andDo(MockMvcResultHandlers.print())
        .andExpect(MockMvcResultMatchers.status().isOk());
    }
}