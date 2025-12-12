package mx.edu.utez.server.modules.user;

import jakarta.validation.Valid;

import mx.edu.utez.server.utils.APIResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class UserController {


    @Autowired
    private UserService userService;

    @GetMapping("")
    public ResponseEntity<APIResponse> findAll() {
        APIResponse response = userService.findAll();
        return new ResponseEntity<>(response, response.getStatus());
    }

    @PostMapping("")
    public ResponseEntity<APIResponse> saveClient(@Valid @RequestBody User payload) {
        APIResponse response = userService.saveUser(payload);
        return new ResponseEntity<>(response, response.getStatus());
    }

    @GetMapping("/{id}")
    public ResponseEntity<APIResponse> findById(@PathVariable("id") Long id) {
        APIResponse response = userService.findById(id);
        return new ResponseEntity<>(response, response.getStatus());
    }

    @PutMapping("")
    public ResponseEntity<APIResponse> updateClient(@RequestBody User payload) {
        APIResponse response = userService.updateUser(payload);
        return new ResponseEntity<>(response, response.getStatus());
    }

    @DeleteMapping("")
    public ResponseEntity<APIResponse> deleteClient(@RequestBody User payload) {
        APIResponse response = userService.deleteUser(payload);
        return new ResponseEntity<>(response, response.getStatus());
    }
}
