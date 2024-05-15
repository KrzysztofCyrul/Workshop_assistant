import React from 'react';
import { View, TextInput, Button, StyleSheet, Text, ScrollView } from 'react-native';
import { Formik } from 'formik';
import * as Yup from 'yup';
import axios from 'axios';

const validationSchema = Yup.object().shape({
  first_name: Yup.string().required('First name is required'),
  last_name: Yup.string(),
  email: Yup.string().email('Invalid email').nullable(),
  phone: Yup.string().nullable(),
  address: Yup.string().nullable(),
  city: Yup.string().nullable(),
  state: Yup.string().nullable(),
  zip_code: Yup.string().nullable(),
});

const ClientForm = () => {
  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Formik
        initialValues={{
          first_name: '',
          last_name: '',
          email: '',
          phone: '',
          address: '',
          city: '',
          state: '',
          zip_code: '',
        }}
        validationSchema={validationSchema}
        onSubmit={(values, { resetForm }) => {
          axios.post('http://192.168.1.11:8000/api/clients/', values)
            .then(response => {
              console.log(response.data);
              resetForm();
            })
            .catch(error => {
              console.log(error.response.data);
            });
        }}
      >
        {({ handleChange, handleBlur, handleSubmit, values, errors, touched }) => (
          <View>
            <TextInput
              style={styles.input}
              onChangeText={handleChange('first_name')}
              onBlur={handleBlur('first_name')}
              value={values.first_name}
              placeholder="First Name"
            />
            {touched.first_name && errors.first_name && <Text style={styles.error}>{errors.first_name}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('last_name')}
              onBlur={handleBlur('last_name')}
              value={values.last_name}
              placeholder="Last Name"
            />
            {touched.last_name && errors.last_name && <Text style={styles.error}>{errors.last_name}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('email')}
              onBlur={handleBlur('email')}
              value={values.email}
              placeholder="Email"
              keyboardType="email-address"
            />
            {touched.email && errors.email && <Text style={styles.error}>{errors.email}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('phone')}
              onBlur={handleBlur('phone')}
              value={values.phone}
              placeholder="Phone"
              keyboardType="phone-pad"
            />
            {touched.phone && errors.phone && <Text style={styles.error}>{errors.phone}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('address')}
              onBlur={handleBlur('address')}
              value={values.address}
              placeholder="Address"
            />
            {touched.address && errors.address && <Text style={styles.error}>{errors.address}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('city')}
              onBlur={handleBlur('city')}
              value={values.city}
              placeholder="City"
            />
            {touched.city && errors.city && <Text style={styles.error}>{errors.city}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('state')}
              onBlur={handleBlur('state')}
              value={values.state}
              placeholder="State"
            />
            {touched.state && errors.state && <Text style={styles.error}>{errors.state}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('zip_code')}
              onBlur={handleBlur('zip_code')}
              value={values.zip_code}
              placeholder="Zip Code"
              keyboardType="numeric"
            />
            {touched.zip_code && errors.zip_code && <Text style={styles.error}>{errors.zip_code}</Text>}
            
            <Button onPress={handleSubmit} title="Submit" />
          </View>
        )}
      </Formik>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    marginBottom: 10,
    padding: 10,
  },
  error: {
    color: 'red',
    marginBottom: 10,
  },
});

export default ClientForm;
