import React, { useState } from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';

import gql from 'graphql-tag';
import {
  Spinner,
} from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import GraphQLErrors from '../../shared/GraphQLErrors';

const getProjectsQuery = gql`
  query {
    projects {
      stringKey
      displayLabel
    }
  }
`;

const compareLabels = (a, b) => a.displayLabel.localeCompare(b.displayLabel, 'en', { sensitivity: 'base' });

const partitionProjectsBySelection = (allProjects, selectedProjects) => {
  const selectedStringKeys = selectedProjects.map((e) => e.stringKey);
  return allProjects.reduce((accumulator, e) => {
    const ix = selectedStringKeys.includes(e.stringKey) ? 0 : 1;
    accumulator[ix].push(e);
    return accumulator;
  }, [[], []]);
};

const OtherProjectsSelect = (props) => {
  const { primaryProject, otherProjects, changeHandler } = props;
  const [allProjects, setAllProjects] = useState([]);
  const {
    loading, error,
  } = useQuery(getProjectsQuery, {
    onCompleted: (res) => {
      setAllProjects(res.projects);
    },
  });

  if (error) return (<GraphQLErrors errors={error} />);
  if (loading) return (<div className="m-3"><Spinner animation="border" variant="warning" /></div>);

  const [selected, available] = partitionProjectsBySelection(allProjects, otherProjects);
  selected.sort(compareLabels);
  available.sort(compareLabels);
  const toOption = (project) => (
    {
      value: project.stringKey,
      label: project.displayLabel,
      isDisabled: (project.stringKey === primaryProject.stringKey),
    }
  );
  const selectedOptions = selected.map((proj) => toOption(proj));
  const options = selectedOptions.concat(available.map((proj) => toOption(proj)));
  const selectionsChanged = (selections) => {
    const updateProjects = selections.map((selection) => ({ stringKey: selection.value }));
    changeHandler(updateProjects);
  };
  return (
    <Select
      aria-label="Other Projects"
      className="col-sm-9"
      options={options}
      value={selectedOptions}
      isMulti
      placeholder="None"
      onChange={selectionsChanged}
    />
  );
};

OtherProjectsSelect.defaultProps = {
};

OtherProjectsSelect.propTypes = {
  changeHandler: PropTypes.func.isRequired,
  primaryProject: PropTypes.shape({
    stringKey: PropTypes.string.isRequired,
  }).isRequired,
  otherProjects: PropTypes.arrayOf(
    PropTypes.shape({
      stringKey: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default OtherProjectsSelect;
