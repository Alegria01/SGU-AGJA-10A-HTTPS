package mx.edu.utez.server.modules.user;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 2, max = 100, message = "El nombre debe tener entre 2 y 100 caracteres")
    @Column(name = "name", nullable = false)
    private String name;

    @NotBlank(message = "El teléfono es obligatorio")
    @Pattern(regexp = "^[0-9]{10}$", message = "numero de telefono no valido")
    @Column(name = "phone", nullable = false)
    private String phone;

    @NotBlank(message = "El email es obligatorio")
    @Pattern(regexp = "^[a-z0-9][a-z0-9_.]{3,}@[a-z]{2,}(\\.[a-z]{2,}){1,2}$", message = "corre no valido")
    @Column(name = "email", nullable = false, unique = true)
    private String email;


    public User() {
    }

    public User(Long id, String name, String phone, String email) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.email = email;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }


}

