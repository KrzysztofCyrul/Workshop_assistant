import React, { useEffect, useState } from "react";
import { useNavigation } from "@react-navigation/native";
import {
  View,
  Text,
  StyleSheet,
  ImageBackground,
  ScrollView,
} from "react-native";
import SelectDropdown from "react-native-select-dropdown";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import { TextInput } from "react-native-gesture-handler";
import { template } from "lodash";

const BASE_URL = "http://10.1.20.208:8000"; // You can change this base URL as needed

const apiLink = {
    mechanics: `${BASE_URL}/api/mechanics/`,
    clients: `${BASE_URL}/api/clients/`,
    car: `${BASE_URL}/api/cars/`,
};

const AddVisitScreen = () => {
  const navigation = useNavigation();
  const [mechanics, setMechanics] = useState([]);
  const [clients, setClients] = useState([]);

  useEffect(() => {
    const fetchMechanics = async () => {
      try {
        const response = await fetch(apiLink.mechanics);
        const data = await response.json();
        setMechanics(data.map(mechanic => ({
          icon: "wrench",
          title: mechanic.first_name + " " + mechanic.last_name,
          
        })));
      } catch (error) {
        console.error("Failed to fetch mechanics:", error);
      }
    };

    const fetchClients = async () => {
        try {
          const response = await fetch(apiLink.clients);
          if (!response.ok) { // Check if response is not ok then throw error
            throw new Error('Network response was not ok');
          }
          const data = await response.json();
          setClients(data.map(client => ({
            icon: "account-circle-outline",
            title: client.first_name + " " + client.last_name + " " + client.phone,
          })));
        } catch (error) {
          console.error("Failed to fetch clients:", error);
          Alert.alert("Error", "Failed to fetch clients: " + error.message); // Displaying alert with error message
        }
      };
      

    fetchMechanics();
    fetchClients();
  }, []);

  return (
    <View style={styles.screen}>
      <ImageBackground
        source={require("../assets/home.jpg")}
        style={{ width: "100%", height: "100%" }}
      >
        <ScrollView style={styles.container}>
            <TextInput 
                style={styles.dropdownButtonStyle}
                placeholder="Data wizyty"
                dataDetectorTypes="calendarEvent"
                ></TextInput>
            <Text></Text>
          <SelectDropdown
            search
            data={mechanics}
            onSelect={(selectedItem, index) => {
              console.log(selectedItem, index);
              test = selectedItem;
            }}
            renderButton={(selectedItem, isOpened) => (
              <View style={styles.dropdownButtonStyle}>
                {selectedItem && (
                  <Icon
                    name={selectedItem.icon}
                    style={styles.dropdownButtonIconStyle}
                  />
                )}
                <Text style={styles.dropdownButtonTxtStyle}>
                  {selectedItem ? selectedItem.title : "Wybierz mechanika"}
                </Text>
                <Icon
                  name={isOpened ? "chevron-up" : "chevron-down"}
                  style={styles.dropdownButtonArrowStyle}
                />
              </View>
            )}
            renderItem={(item, index, isSelected) => (
              <View
                style={{
                  ...styles.dropdownItemStyle,
                  ...(isSelected && { backgroundColor: "#D2D9DF" }),
                }}
              >
                <Icon name={item.icon} style={styles.dropdownItemIconStyle} />
                <Text style={styles.dropdownItemTxtStyle}>{item.title}</Text>
              </View>
            )}
            showsVerticalScrollIndicator={false}
            dropdownStyle={styles.dropdownMenuStyle}
          />
          <Text></Text>
          <SelectDropdown
            search
            data={clients}
            onSelect={(selectedItem, index) => {
              console.log(selectedItem, index);
            }}
            renderButton={(selectedItem, isOpened) => (
              <View style={styles.dropdownButtonStyle}>
                {selectedItem && (
                  <Icon
                    name={selectedItem.icon}
                    style={styles.dropdownButtonIconStyle}
                  />
                )}
                <Text style={styles.dropdownButtonTxtStyle}>
                  {selectedItem ? selectedItem.title : "Wybierz klienta"}
                </Text>
                <Icon
                  name={isOpened ? "chevron-up" : "chevron-down"}
                  style={styles.dropdownButtonArrowStyle}
                />
              </View>
            )}
            renderItem={(item, index, isSelected) => (
              <View
                style={{
                  ...styles.dropdownItemStyle,
                  ...(isSelected && { backgroundColor: "#D2D9DF" }),
                }}
              >
                <Icon name={item.icon} style={styles.dropdownItemIconStyle} />
                <Text style={styles.dropdownItemTxtStyle}>{item.title}</Text>
              </View>
            )}
            showsVerticalScrollIndicator={false}
            dropdownStyle={styles.dropdownMenuStyle}
          />
        </ScrollView>
      </ImageBackground>
    </View>
  );
};

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: "#fff",
  },
  container: {
    marginTop: 0,
    flex: 1,
    padding: 20,
  },
  dropdownButtonStyle: {
    width: "auto",
    height: 50,
    backgroundColor: "#E9ECEF",
    borderRadius: 12,
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 12,
  },
  dropdownButtonTxtStyle: {
    flex: 1,
    fontSize: 16,
    fontWeight: "500",
    color: "#151E26",
  },
  dropdownButtonArrowStyle: {
    fontSize: 28,
  },
  dropdownButtonIconStyle: {
    fontSize: 28,
    marginRight: 8,
  },
  dropdownMenuStyle: {
    backgroundColor: "#E9ECEF",
    borderRadius: 8,
  },
  dropdownItemStyle: {
    width: "100%",
    flexDirection: "row",
    paddingHorizontal: 12,
    justifyContent: "center",
    alignItems: "center",
    paddingVertical: 8,
  },
  dropdownItemTxtStyle: {
    flex: 1,
    fontSize: 18,
    fontWeight: "500",
    color: "#151E26",
  },
  dropdownItemIconStyle: {
    fontSize: 28,
    marginRight: 8,
  },
});

export default AddVisitScreen;
