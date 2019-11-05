
import java.util.Arrays;
import java.util.Comparator;

public class RCSortStabilityJ {

  private static final String[] cityList;

  static {
    cityList = new String[] { "UK  London", "US  New York", "US  Birmingham", "UK  Birmingham", };
  }

  public RCSortStabilityJ() {
    return;
  }

  public static void main(String[] args) {

    String[] cn;

    cn = new String[cityList.length];
    System.arraycopy(cityList, 0, cn, 0, cityList.length);
    System.out.println("\nBefore sort:");
    for (String city : cn) {
      System.out.println(city);
    }

    Arrays.sort(cn, new CityComparator());

    System.out.println();
    System.out.println("\nAfter sort on city:");
    for (String city : cn) {
      System.out.println(city);
    }

    cn = new String[cityList.length];
    System.arraycopy(cityList, 0, cn, 0, cityList.length);
    System.out.println("\nBefore sort:");
    for (String city : cn) {
      System.out.println(city);
    }

    Arrays.sort(cn, new CountryComparator());

    System.out.println("\nAfter sort on country:");
    for (String city : cn) {
      System.out.println(city);
    }

    System.out.println();

    return;
  }

  static class CityComparator implements Comparator<String> {
    public int compare(String lft, String rgt) {
      return lft.substring(4).compareTo(rgt.substring(4));
    }
  }

  static class CountryComparator implements Comparator<String> {
    public int compare(String lft, String rgt) {
      return lft.substring(0, 2).compareTo(rgt.substring(0, 2));
    }
  }
}

