import React, { useEffect } from 'react';
import { AsyncStorage } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import jwtDecode from 'jwt-decode';

const withAuth = (WrappedComponent) => {
  return (props) => {
    const navigation = useNavigation();

    useEffect(() => {
      const checkAuth = async () => {
        const token = await AsyncStorage.getItem('access');
        if (!token) {
          navigation.navigate('Login');
        } else {
          const decodedToken = jwtDecode(token);
          const currentTime = Date.now() / 1000;
          if (decodedToken.exp < currentTime) {
            await AsyncStorage.removeItem('access');
            navigation.navigate('Login');
          }
        }
      };

      checkAuth();
    }, [navigation]);

    return <WrappedComponent {...props} />;
  };
};

const login = async () => {
    try {
        const response = await axios.post(apiLink.token, {
            username,
            password
        });
        const { access, refresh } = response.data;

        await AsyncStorage.setItem('access', access);
        await AsyncStorage.setItem('refresh', refresh);

        navigation.navigate('Home'); // Przekierowanie po udanym logowaniu
    } catch (error) {
        Alert.alert('Login failed', 'Sprawdź login i hasło');
    }
};

export default withAuth;
export { login };