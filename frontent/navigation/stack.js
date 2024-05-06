import { createStackNavigator } from "@react-navigation/stack";
import HomeScreen from "../screens/home-screen";
import VisitScreen from "../screens/visit-screen";
import { Image } from "react-native";

const Stack = createStackNavigator();

function LogoTitle() {
  return (
    <Image
      style={{ width: 50, height: 50 }}
      source={require("../assets/favicon.png")}
    />
  );
}

export const HomeStack = () => {
  return (
    <Stack.Navigator>
      <Stack.Screen
        name="Home"
        component={HomeScreen}
        options={{ headerShown: false }}
      />
      <Stack.Screen name="Visit" component={VisitScreen} />
    </Stack.Navigator>
  );
};
