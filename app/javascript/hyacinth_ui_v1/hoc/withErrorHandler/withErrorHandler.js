import React, { Component } from 'react';
import { Alert } from 'react-bootstrap';

const withErrorHandler = (WrappedComponent, axios) => class extends Component {
    state = {
      errors: null,
    }

    componentWillMount() {
      this.reqInterceptor = axios.interceptors.request.use((req) => {
        this.setState({ errors: null });
        return req;
      });

      this.resInterceptor = axios.interceptors.response.use(res => res, (error) => {
        if (error.response.status === 404) {
          this.props.history.push('/404');
        } else {
          this.setState({
            errors: error.response.data.errors,
          });
        }
        return Promise.reject(error);
      });
    }

    componentWillUnmount() {
      axios.interceptors.request.eject(this.reqInterceptor);
      axios.interceptors.response.eject(this.resInterceptor);
    }

    errorComfirmedHandler = () => {
      this.setState({ error: null });
    }

    render() {
      let errorMessages = '';

      if (this.state.errors) {
        errorMessages = (
          <Alert variant="danger">
            <Alert.Heading as="h5">The following error(s) occurred:</Alert.Heading>
            <ul>
              {this.state.errors.map((error, index) => (<li key={index}>{error.title}</li>))}
            </ul>
          </Alert>
        );
      }

      return (
        <>
          {errorMessages}
          <WrappedComponent {...this.props} />
        </>
      );
    }
};

export default withErrorHandler;
