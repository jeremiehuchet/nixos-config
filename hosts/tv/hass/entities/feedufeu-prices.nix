{ lib, config, ... }:

{
  config = {
    services.home-assistant.config = {
      rest = [
        {
          method = "POST";
          resource = "https://feedufeu.com/wp-admin/admin-ajax.php";
          # example response:
          # {
          #  "price_html": "<span class=\"woocommerce-Price-amount amount\"><bdi>425,00&nbsp;<span class=\"woocommerce-Price-currencySymbol\">&euro;<\/span><\/bdi><\/span>",
          #  "original_price_html": "<span class=\"woocommerce-Price-amount amount\"><bdi>425,00&nbsp;<span class=\"woocommerce-Price-currencySymbol\">&euro;<\/span><\/bdi><\/span>"
          # }
          scan_interval = 86400; # seconds or 1 day
          sensor = let
            extract_price = "value_json | price_html | regex_replace(find='.*([0-9]+),([0-9]+).*', replace='\\1.\\2') | float";
          in = [ 
            {
              name = "feedufeu_price_975kg";
              unique_id = "feedufeu_price_975kg";
              value_template = "{{ ${extract_price} }}";
              state_class = "measurement";
              icon = "mdi:currency-eur";
              unit_of_measurement = "€";
            }
            {
              name = "feedufeu_price_15kg";
              unique_id = "feedufeu_price_15kg";
              value_template = "
                {% set prix_65_sacs_15kg = ${extract_price} | float %}
                {{ prix_65_sacs_15kg / 65 | round(2) }}
              ";
              state_class = "measurement";
              icon = "mdi:currency-eur";
              unit_of_measurement = "€";
            }
            {
              name = "feedufeu_price_1kg";
              unique_id = "feedufeu_price_1kg";
              value_template = "
                {% set prix_65_sacs_15kg = ${extract_price} %}
                {{ prix_65_sacs_15kg / 65 / 15 | round(2) }}
              ";
              state_class = "measurement";
              icon = "mdi:currency-eur";
              unit_of_measurement = "€";
            }
          ];
        }
      ];
    };
  };
}
