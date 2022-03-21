import React from 'react';
import {
  Button,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';
import { switchToUserMutation } from '../../graphql/users';

function SwitchToUserButton({ userId }) {
  const history = useHistory();
  const [switchToUser, { error: mutationErrors }] = useMutation(switchToUserMutation);

  const onClickHandler = () => {
    switchToUser({
      variables: { input: { id: userId } },
    }).then(() => {
      history.go(0); // reload the page
    });
  };

  return (
    <Button variant="secondary" onClick={onClickHandler}>Switch to this user</Button>
  );
}

SwitchToUserButton.propTypes = {
  userId: PropTypes.string.isRequired,
};

export default SwitchToUserButton;
