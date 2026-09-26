{ lib, config, ... }:

{
  config = {
    services.home-assistant.config = {
      rest = [
        {
          method = "POST";
          resource = "https://feedufeu.com/wp-admin/admin-ajax.php";
          payload = "action=wdr_ajax"
            + "&method=get_price_html"
            + "&product_id=356"
            + "&awdr_nonce=ac714edf33";
          headers = {
            Referer = "https://feedufeu.com/produit/granules-de-bois-palettes/";
            User-Agent = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:153.0) Gecko/20100101 Firefox/153.0";
          };
          # example response:
          # {
          #  "price_html": "<span class=\"woocommerce-Price-amount amount\"><bdi>425,00&nbsp;<span class=\"woocommerce-Price-currencySymbol\">&euro;<\/span><\/bdi><\/span>",
          #  "original_price_html": "<span class=\"woocommerce-Price-amount amount\"><bdi>425,00&nbsp;<span class=\"woocommerce-Price-currencySymbol\">&euro;<\/span><\/bdi><\/span>"
          # }
          scan_interval = 86400; # seconds or 1 day
          sensor = let
            extract_price = "value_json.price_html | regex_replace('.*([0-9]+),([0-9]+).*', '\\1.\\2') | float";
          in [ 
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
