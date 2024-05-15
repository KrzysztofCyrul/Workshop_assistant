import React from 'react';
import { View, TextInput, Button, StyleSheet, Text, ScrollView } from 'react-native';
import { Formik } from 'formik';
import * as Yup from 'yup';
import axios from 'axios';
import { apiLink } from "../api"; // Import linków API


const validationSchema = Yup.object().shape({
  brand: Yup.string().required('Brand is required'),
  model: Yup.string().required('Model is required'),
  year: Yup.number().nullable(),
  vin: Yup.string().nullable(),
  license_plate: Yup.string().nullable(),
  client: Yup.string().required('Client is required'),
});

const ClientCarForm = ({ onClose }) => {
  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Formik
        initialValues={{
          brand: '',
          model: '',
          year: '',
          vin: '',
          license_plate: '',
          client: '',
        }}
        validationSchema={validationSchema}
        onSubmit={(values, { resetForm }) => {
          axios.post(apiLink.cars, values)
            .then(response => {
              console.log(response.data);
              resetForm();
              onClose(); // zamykamy modal po udanym dodaniu pojazdu
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
              onChangeText={handleChange('brand')}
              onBlur={handleBlur('brand')}
              value={values.brand}
              placeholder="Brand"
              placeholderTextColor={"black"}

            />
            {touched.brand && errors.brand && <Text style={styles.error}>{errors.brand}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('model')}
              onBlur={handleBlur('model')}
              value={values.model}
              placeholder="Model"
              placeholderTextColor={"black"}

            />
            {touched.model && errors.model && <Text style={styles.error}>{errors.model}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('year')}
              onBlur={handleBlur('year')}
              value={values.year}
              placeholder="Year"
              keyboardType="numeric"
              placeholderTextColor={"black"}

            />
            {touched.year && errors.year && <Text style={styles.error}>{errors.year}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('vin')}
              onBlur={handleBlur('vin')}
              value={values.vin}
              placeholder="VIN"
              placeholderTextColor={"black"}

            />
            {touched.vin && errors.vin && <Text style={styles.error}>{errors.vin}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('license_plate')}
              onBlur={handleBlur('license_plate')}
              value={values.license_plate}
              placeholder="License Plate"
              placeholderTextColor={"black"}

            />
            {touched.license_plate && errors.license_plate && <Text style={styles.error}>{errors.license_plate}</Text>}
            
            <TextInput
              style={styles.input}
              onChangeText={handleChange('client')}
              onBlur={handleBlur('client')}
              value={values.client}
              placeholder="Client ID"
              placeholderTextColor={"black"}

            />
            {touched.client && errors.client && <Text style={styles.error}>{errors.client}</Text>}
            
            <Button onPress={handleSubmit} title="Submit" />
            <Button onPress={onClose} title="Cancel" color="red" />
          </View>
        )}
      </Formik>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
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

export default ClientCarForm;
