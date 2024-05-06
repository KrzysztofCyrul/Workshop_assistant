import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, FlatList, ActivityIndicator, TouchableOpacity } from 'react-native';
import Collapsible from 'react-native-collapsible';
import _ from 'lodash';


const VisitScreen = ({ navigation }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [expandedId, setExpandedId] = useState(null);

  const statusColorMapping = {
    in_progress: '#00ff00',  // Green for in progress
    pending: '#ffa500',      // Orange for pending
    done: '#ff0000',         // Red for done
    default: '#808080'       // Default grey color for undefined status
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('http://192.168.1.11:8000/api/visit/');
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        const jsonData = await response.json();
  
        // Sortowanie danych po dacie
        const sortedData = jsonData.sort((b, a) => {
          return new Date(a.date) - new Date(b.date);
        });
  
        setData(sortedData);
        setLoading(false);
      } catch (error) {
        setError(error.message);
        setLoading(false);
      }
    };
    fetchData();
  }, []);
  
  const handleStatusChange = async (id) => {
    const updatedData = data.map(item => {
      if (item.id === id) {
        let newStatus = 'in_progress'; // Start cycling statuses from 'in_progress'
        switch (item.status) {
          case 'in_progress':
            newStatus = 'pending';
            break;
          case 'pending':
            newStatus = 'done';
            break;
          case 'done':
            newStatus = 'in_progress';
            break;
          default:
            newStatus = 'in_progress'; // Set to in_progress if undefined
            break;
        }
        updateStatusInDatabase(id, newStatus); // Send updated status to server
        return { ...item, status: newStatus };
      }
      return item;
    });
    setData(updatedData);
  };

  const updateStatusInDatabase = async (id, newStatus) => {
    try {
      const response = await fetch(`http://192.168.1.11:8000/api/visit/${id}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus })
      });
      if (!response.ok) {
        throw new Error('Failed to update status');
      }
    } catch (error) {
      console.error('Error updating status:', error);
    }
  };

  const renderItem = ({ item }) => (
    <View style={styles.item}>
      <Text style={styles.title}>{item.date}</Text>
      <TouchableOpacity
        style={[
          styles.statusIndicator,
          { backgroundColor: statusColorMapping[item.status] || statusColorMapping.default ,
          }
        ]}
        onPress={() => handleStatusChange(item.id)}
      >
        <View style={styles.dot}>
        </View>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => setExpandedId(expandedId === item.id ? null : item.id)}>
        <View style={styles.header}>
          <Text style={styles.collapsHead}>id: {item.id} {('\n')}samochód: {item.cars.map(car => `${car.brand} ${car.model} ${car.year} \nVIN: ${car.vin}`).join(', ')}</Text>
        </View>
      </TouchableOpacity>
      <Collapsible collapsed={expandedId !== item.id}>
        <View style={styles.content}>
          <Text>{item.cars.map(car => `${car.brand} ${car.model} ${car.year} ${car.vin}`).join(', ')}</Text>
          <Text style={styles.client}>Klient: {item.clients.map(client => `${client.first_name} ${client.phone}`)}</Text>
          <Text></Text>
          <Text style={styles.title}>{item.name}</Text>
          <Text> * {item.description.split(',').join('\n *')}</Text>
        </View>
      </Collapsible>
    </View>
  );

  return (
    <SafeAreaView style={styles.screen}>
      {loading ? (
        <ActivityIndicator size="large" color="#0000ff" />
      ) : error ? (
        <Text style={styles.error}>Failed to load data: {error}</Text>
      ) : (
        <FlatList
          data={data}
          keyExtractor={item => item.id.toString()}
          renderItem={renderItem}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  screen: {
    padding: 20
  },
  item: {
    width: '100%',
    padding: 10,
    paddingRight: 20,
    paddingLeft: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#cccccc',
    flexDirection: 'column',
    // alignItems: 'center',
    // justifyContent: 'space-between',
  },
  header: {
    flexDirection: 'column',
    alignItems: 'left',
    textAlign: 'center',
    // justifyContent: 'space-between',
    width: '100%',
    paddingVertical: 10,
    paddingHorizontal: 5,
  },
  content: {
    paddingVertical: 10,
  },
  title: {
    fontWeight: 'bold',
    textAlign: 'center',
  },
  error: {
    color: 'red',
  },
  statusIndicator: {
    width: 24,
    height: 24,
    borderRadius: 12,
  },
  dot: {
    width: 24,
    height: 24,
    borderRadius: 12,
  },
  collapsHead: {
    fontSize: 16,
    fontWeight: 'bold',
    textTransform: 'uppercase',
  },
  client: {
    fontWeight: 'bold',
    fontSize: 13,
    textAlign: 'center',
  },
});

export default VisitScreen;
