import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Repeatable;

@Retention(RetentionPolicy.RUNTIME)

@interface Authors {
    Author[] value();
}
