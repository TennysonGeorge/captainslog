import React, { useState } from "react"
import { Text, TextInput } from "react-native"

import { CreateToken, SetToken } from "../repository/token"
import styles from "../styles"
import strings from "../strings"

import AppView from "../component/AppView"
import Button from "../component/Button"
import FormField from "../component/FormField"
import Header from "../component/Header"

type LoginProps = {
  setToken: SetToken
  createToken: CreateToken
}

export default function Login(props: LoginProps) {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [errorMessage, setErrorMessage] = useState("")

  const login = () => {
    setErrorMessage("")

    if (!email && !password) {
      setErrorMessage(strings.missingValues(strings.email, strings.password))
    } else if (!email) {
      setErrorMessage(strings.missingValues(strings.email))
    } else if (!password) {
      setErrorMessage(strings.missingValues(strings.password))
    } else {
      props.createToken(email, password)
        .then((token) => {
          console.log("token:", token)
          props.setToken(token)
            .then(() => {
              console.log("saved token to secure store")
            })
            .catch((err) => {
              console.log("storage error:", err)
              setErrorMessage(strings.invalidLogin)
            })
        })
        .catch((err) => {
          console.log("login error:", err)
          setErrorMessage(strings.invalidLogin)
        })
    }
  }

  return <AppView>
    <Header>{strings.login}</Header>

    <FormField>
      <Text style={styles.inputLabel}>{strings.email}</Text>
      <TextInput
        style={styles.textInput}
        onChangeText={(val) => setEmail(val)}
      />
    </FormField>

    <FormField>
      <Text style={styles.inputLabel}>{strings.password}</Text>
      <TextInput
        style={styles.textInput}
        onChangeText={(val) => setPassword(val)}
        secureTextEntry={true}
      />
    </FormField>

    {!errorMessage ? null :
      <FormField>
        <Text style={styles.errorMessage}>{errorMessage}</Text>
      </FormField>}

    <FormField>
      <Button label={strings.login} onPress={login} />
    </FormField>
  </AppView>
}
