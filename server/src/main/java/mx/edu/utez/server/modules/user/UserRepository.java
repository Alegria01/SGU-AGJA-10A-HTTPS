package mx.edu.utez.server.modules.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Modifying
    @Query(value = "DELETE FROM user WHERE id = :id ", nativeQuery = true)
    void delete(@Param("id") Long id);

    Optional<User> findByEmail(String email);
}