import React, { useEffect, useState } from 'react';
import { View, Text, TextInput, Button, Alert, StyleSheet } from 'react-native';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useNavigation } from '@react-navigation/native';
import { apiLink } from '../api';

const LoginScreen = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const navigation = useNavigation();

    useEffect(() => {
        const checkAuth = async () => {
            const token = await AsyncStorage.getItem('access');
            if (token) {
                navigation.navigate('Home');
                alert('You are already logged in');
            }
        };

        checkAuth();
    }, []);

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

    return (
        <View style={styles.container}>
            <TextInput
                style={styles.input}
                placeholder="Username"
                value={username}
                onChangeText={setUsername}
            />
            <TextInput
                style={styles.input}
                placeholder="Password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
            />
            <Button title="Login" onPress={login} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        padding: 16
    },
    input: {
        height: 40,
        borderColor: 'gray',
        borderWidth: 1,
        marginBottom: 12,
        paddingHorizontal: 8
    }
});

export default LoginScreen;
