import React, { useEffect, useState } from "react";
import { useNavigation } from "@react-navigation/native";
import {
  View,
  Text,
  StyleSheet,
  ImageBackground,
  ScrollView,
  Alert,
  Modal,
} from "react-native";
import SelectDropdown from "react-native-select-dropdown";
import Icon from "react-native-vector-icons/MaterialCommunityIcons";
import { TextInput } from "react-native-gesture-handler";
import DateTimePicker from "@react-native-community/datetimepicker";
import ClientForm from "../forms/ClientForm";
import ClientCarForm from "../forms/ClientCarForm";
import api from "../api"; // Importuj skonfigurowane axios
import { apiLink } from "../api"; // Importuj linki API
import AsyncStorage from "@react-native-async-storage/async-storage";

const AddVisitScreen = () => {
  const navigation = useNavigation();
  const [mechanics, setMechanics] = useState([]);
  const [clients, setClients] = useState([]);
  const [cars, setCars] = useState([]);
  const [clientModalVisible, setClientModalVisible] = useState(false);
  const [carModalVisible, setCarModalVisible] = useState(false);

  useEffect(() => {
    const checkAuth = async () => {
      const token = await AsyncStorage.getItem('access');
      if (!token) {
        navigation.navigate('Login');
      }
    };

    const fetchMechanics = async () => {
      try {
        const response = await api.get(apiLink.mechanics);
        const data = response.data;
        setMechanics(
          data.map((mechanic) => ({
            icon: "wrench",
            title: mechanic.first_name + " " + mechanic.last_name,
          }))
        );
      } catch (error) {
        console.error("Failed to fetch mechanics:", error);
      }
    };

    const fetchClients = async () => {
      try {
        const response = await api.get(apiLink.clients);
        const data = response.data;
        setClients(
          data.map((client) => ({
            icon: "account-circle-outline",
            title:
              client.first_name + " " + client.last_name + " " + client.phone,
          }))
        );
      } catch (error) {
        console.error("Failed to fetch clients:", error);
      }
    };

    const fetchCars = async () => {
      try {
        const response = await api.get(apiLink.cars);
        const data = response.data;
        setCars(
          data.map((car) => ({
            icon: "car",
            title: car.brand + " " + car.model + " " + car.license_plate,
          }))
        );
      } catch (error) {
        console.error("Failed to fetch cars:", error);
      }
    };

    checkAuth();
    fetchMechanics();
    fetchClients();
    fetchCars();
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
          />

          <Text></Text>

          <View>
            <Text style={styles.dropdownButtonStyle}>
              <DateTimePicker
                style={styles.dateTimePickerButtonStyle}
                testID="dateTimePicker"
                value={new Date()}
                mode="date"
                is24Hour={true}
                display="default"
              />
              <DateTimePicker
                style={styles.dateTimePickerButtonStyle}
                testID="dateTimePicker"
                value={new Date()}
                mode="time"
                is24Hour={true}
                display="default"
              />
            </Text>
          </View>

          <Text></Text>
          <SelectDropdown
            search
            data={mechanics}
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
          <View>
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
                  <Icon
                    name="plus"
                    size={24}
                    style={styles.dropdownAddButtonIconStyle}
                    onPress={() => setClientModalVisible(true)}
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
          </View>

          <Text></Text>
          <View>
            <SelectDropdown
              search
              data={cars}
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
                    {selectedItem ? selectedItem.title : "Wybierz pojazd"}
                  </Text>
                  <Icon
                    name={isOpened ? "chevron-up" : "chevron-down"}
                    style={styles.dropdownButtonArrowStyle}
                  />
                  <Icon
                    name="plus"
                    size={24}
                    style={styles.dropdownAddButtonIconStyle}
                    onPress={() => setCarModalVisible(true)}
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
          </View>

          <Modal
            animationType="slide"
            transparent={true}
            visible={clientModalVisible}
            onRequestClose={() => setClientModalVisible(false)}
          >
            <View style={styles.modalOverlay}>
              <View style={styles.modalContent}>
                <ClientForm onClose={() => setClientModalVisible(false)} />
              </View>
            </View>
          </Modal>

          <Modal
            animationType="slide"
            transparent={true}
            visible={carModalVisible}
            onRequestClose={() => setCarModalVisible(false)}
          >
            <View style={styles.modalOverlay}>
              <View style={styles.modalContent}>
                <ClientCarForm onClose={() => setCarModalVisible(false)} />
              </View>
            </View>
          </Modal>
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
  dateTimePickerButtonStyle: {
    width: "auto",
    height: 50,
    backgroundColor: "#E9ECEF",
    padding: 20,
  },
  addButton: {
    backgroundColor: "#007BFF",
    borderRadius: 50,
    padding: 10,
    marginLeft: 10,
  },
  modalOverlay: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0, 0, 0, 0.5)",
  },
  modalContent: {
    width: "80%",
    padding: 20,
    backgroundColor: "white",
    borderRadius: 10,
  },
});

export default AddVisitScreen;
