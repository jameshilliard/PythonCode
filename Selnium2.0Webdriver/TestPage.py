__author__ = 'royxu'

from selenium import webdriver

from selenium.common.exceptions import TimeoutException

from selenium.webdriver.support.ui import WebDriverWait

from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Firefox()

driver.get("http://www.google.com.hk")

inputElement = driver.find_element_by_name("q")

inputElement.send_keys("Cheese!")


inputElement.submit()

print driver.title

try:
    WebDriverWait(driver, 10).until(EC.title_contains("cheese!"))

    print driver.title


finally:

    driver.quit()

