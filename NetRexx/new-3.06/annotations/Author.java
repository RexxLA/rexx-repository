import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Repeatable;

@Retention(RetentionPolicy.RUNTIME)

@Repeatable(Authors.class)

@interface Author {
  String name();
  String date() default "now";
}
