import React, { useEffect, useState } from "react";
import {
  Alert,
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  FlatList,
  ActivityIndicator,
  TouchableOpacity,
} from "react-native";
import Collapsible from "react-native-collapsible";
import _ from "lodash";

const BASE_URL = "http://192.168.1.11:8000"; // You can change this base URL as needed

const VisitScreen = ({ navigation }) => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [expandedId, setExpandedId] = useState(null);
  const [striked, setStriked] = useState({}); // Stan dla przekreślonych linii

  const statusColorMapping = {
    in_progress: "#00ff00", // Green for in progress
    pending: "#ffa500", // Orange for pending
    done: "#ff0000", // Red for done
    default: "#808080", // Default grey color for undefined status
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(`${BASE_URL}/api/visits/`);
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        const jsonData = await response.json();
        const sortedData = jsonData.sort(
          (b, a) => new Date(a.date) - new Date(b.date)
        );
        setData(sortedData);
        const strikedData = jsonData.reduce(
          (acc, item) => ({ ...acc, [item.id]: item.striked_lines || {} }),
          {}
        );
        setStriked(strikedData);
        setLoading(false);
      } catch (error) {
        setError(error.message);
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const confirmStatusChange = (id, currentStatus) => {
    let newStatus;
    switch (currentStatus) {
      case "in_progress":
        newStatus = "pending";
        confirmStatus = "Oczekujący";
        break;
      case "pending":
        newStatus = "done";
        confirmStatus = "Zakończony";
        break;
      case "done":
        newStatus = "in_progress";
        confirmStatus = "W trakcie";
        break;
      default:
        newStatus = "in_progress"; // Set to in_progress if undefined
        break;
    }

    Alert.alert(
      "Potwierdzenie zmiany statusu",
      `Czy na pewno chcesz zmienić status na ${confirmStatus}?`,
      [
        {
          text: "Anuluj",
          style: "cancel",
        },
        { text: "Potwierdź", onPress: () => handleStatusChange(id, newStatus) },
      ]
    );
  };

  const handleStatusChange = async (id, newStatus) => {
    const updatedData = data.map((item) => {
      if (item.id === id) {
        updateStatusInDatabase(id, newStatus); // Send updated status to server
        return { ...item, status: newStatus };
      }
      return item;
    });
    setData(updatedData);
  };

  const updateStatusInDatabase = async (id, newStatus) => {
    try {
      const response = await fetch(`${BASE_URL}/api/visit/${id}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ status: newStatus }),
      });
      if (!response.ok) {
        throw new Error("Failed to update status");
      }
    } catch (error) {
      console.error("Error updating status:", error);
    }
  };

  const toggleStriked = (id, index) => {
    setStriked((prev) => {
      const newStriked = {
        ...prev,
        [id]: {
          ...(prev[id] || {}),
          [index]: !(prev[id] && prev[id][index]),
        },
      };
      updateStrikedOnServer(id, newStriked[id]); // Aktualizuj stan na serwerze
      return newStriked;
    });
  };

  const updateStrikedOnServer = async (id, strikedLines) => {
    try {
      const response = await fetch(
        `${BASE_URL}/api/visit/update-striked/${id}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ strikedLines }),
        }
      );
      if (!response.ok) {
        const text = await response.text();
        console.error("Server response:", text);
        try {
          const data = JSON.parse(text);
          console.error("Parsed server response:", data);
        } catch (error) {
          console.error("Failed to parse server response:", error);
        }
        throw new Error("Failed to update striked lines");
      }
    } catch (error) {
      console.error("Error updating striked lines:", error);
    }
  };

  const renderItem = ({ item }) => (
    <View style={styles.item}>
      <Text style={styles.title}>
        {item.date} id: {item.id}
      </Text>
      <TouchableOpacity
        style={[
          styles.statusIndicator,
          {
            backgroundColor:
              statusColorMapping[item.status] || statusColorMapping.default,
          },
        ]}
        onPress={() => confirmStatusChange(item.id, item.status)}
      >
        <View style={styles.dot}></View>
      </TouchableOpacity>

      <TouchableOpacity
        onPress={() => setExpandedId(expandedId === item.id ? null : item.id)}
      >
        <View style={styles.header}>
          <Text style={styles.collapsHead}>
            Samochód:{" "}
            {item.cars
              .map(
                (car) =>
                  `${car.brand} ${car.model} ${car.year} \nVIN: ${car.vin}`
              )
              .join(", ")}
          </Text>
        </View>
      </TouchableOpacity>

      <Collapsible collapsed={expandedId !== item.id}>
        <View style={styles.content}>
          <Text style={styles.client}>
            Klient:{" "}
            {item.clients.map(
              (client) => `${client.first_name} ${client.phone}`
            )}
          </Text>
          <Text></Text>
          <Text style={styles.title}>{item.name}</Text>
          {item.description.split(",").map((line, index) => (
            <TouchableOpacity
              key={index}
              onPress={() => toggleStriked(item.id, index)}
            >
              <Text
                style={
                  striked[item.id] && striked[item.id][index]
                    ? styles.striked
                    : undefined
                }
              >
                * {line}
              </Text>
            </TouchableOpacity>
          ))}
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
          keyExtractor={(item) => item.id.toString()}
          renderItem={renderItem}
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  description: {
    padding: 5,
    fontSize: 18,
    fontWeight: "bold",
  },
  striked: {
    textDecorationLine: "line-through",
  },
  screen: {
    padding: 20,
  },
  item: {
    width: "100%",
    padding: 10,
    paddingRight: 5,
    paddingLeft: 5,
    borderBottomWidth: 1,
    borderBottomColor: "#cccccc",
    flexDirection: "column",
    // alignItems: 'center',
    // justifyContent: 'space-between',
  },
  header: {
    flexDirection: "column",
    alignItems: "left",
    textAlign: "center",
    // justifyContent: 'space-between',
    width: "100%",
    paddingVertical: 10,
    paddingHorizontal: 5,
  },
  content: {
    paddingVertical: 10,
  },
  title: {
    fontWeight: "bold",
    textAlign: "center",
  },
  error: {
    color: "red",
  },
  statusIndicator: {
    width: 24,
    height: 24,
    borderRadius: 12,
    alignSelf: "flex-end",
  },
  dot: {
    width: 24,
    height: 24,
    borderRadius: 12,
  },
  collapsHead: {
    fontSize: 16,
    fontWeight: "bold",
    textTransform: "uppercase",
  },
  client: {
    fontWeight: "bold",
    fontSize: 13,
    textAlign: "center",
  },
});

export default VisitScreen;
