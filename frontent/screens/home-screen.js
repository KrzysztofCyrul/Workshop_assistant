import { useNavigation } from "@react-navigation/native";
import { useEffect } from "react";
import {
  View,
  Text,
  Button,
  StyleSheet,
  SafeAreaView,
  ImageBackground,
  Alert,
} from "react-native";
import { ScrollView, TouchableOpacity } from "react-native-gesture-handler";
import withAuth from "../auth/auth";

const HomeScreen = () => {
  useEffect(() => {
    
  }, []);


  const navigation = useNavigation();
  const handlePress = (buttonName) => {
    Alert.alert(`Naciśnięto przycisk ${buttonName}`);
  };
  return (
    <View style={styles.screen}>
      <ImageBackground
        source={require("../assets/home.jpg")}
        style={{ width: "100%", height: "100%" }}
      >
        <ScrollView style={styles.container}>
          <TouchableOpacity
            title="Przycisk 1"
            onPress={() => navigation.navigate("Visit")}
            color="#007bff"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Przycisk 1</Text>
          </TouchableOpacity>
          <TouchableOpacity
            title="Przycisk 2"
            onPress={() => navigation.navigate("AddVisit")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Przycisk 2</Text>
          </TouchableOpacity>
          <TouchableOpacity
            title="Przycisk 3"
            onPress={() => navigation.navigate("AddClient")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Przycisk 3</Text>
          </TouchableOpacity>
          <TouchableOpacity
            title="Login"
            onPress={() => navigation.navigate("Login")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Login</Text>
          </TouchableOpacity>
          <TouchableOpacity
            title="Logout"
            onPress={() => navigation.navigate("Logout")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Logout</Text>
          </TouchableOpacity>
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
    marginTop: 35,
    flex: 1,
    // justifyContent: 'space-around',
    padding: 20,
  },
  button: {
    marginVertical: 10,
    backgroundColor: "#DDDDDD",
    padding: 50,
    alignItems: "center",
    borderRadius: 10,
    borderColor: "black",
    borderWidth: 2,
  },
  buttonText: {
    fontSize: 20,
    color: "black",
  },
});

export default withAuth(HomeScreen);
