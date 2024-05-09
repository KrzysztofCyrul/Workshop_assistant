import { useNavigation } from "@react-navigation/native";
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

const HomeScreen = () => {
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
            onPress={() => handlePress("3")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Przycisk 3</Text>
          </TouchableOpacity>
          <TouchableOpacity
            title="Przycisk 4"
            onPress={() => handlePress("4")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Przycisk 4</Text>
          </TouchableOpacity>
          <TouchableOpacity
            title="Przycisk 5"
            onPress={() => handlePress("5")}
            color="#28a745"
            style={styles.button}
          >
            <Text style={styles.buttonText}>Przycisk 5</Text>
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

export default HomeScreen;
