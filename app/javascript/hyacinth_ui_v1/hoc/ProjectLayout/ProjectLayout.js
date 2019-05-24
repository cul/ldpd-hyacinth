import React, { Component } from 'react';
import PropTypes from 'prop-types';
import producer from 'immer';

import ContextualNavbar from '../../components/layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';

class ProjectLayout extends Component {
  state = {
    project: {
      displayLabel: '',
    },
  }

  componentDidMount = () => {
    const { stringKey } = this.props;

    hyacinthApi.get(`/projects/${stringKey}`)
      .then((res) => {
        this.setState(producer((draft) => {
          draft.project.displayLabel = res.data.project.displayLabel;
        }));
      });
  }


  render() {
    const { project: { displayLabel } } = this.state;
    const { children } = this.props;

    return (
      <>
        <ContextualNavbar
          title={`Project | ${displayLabel}`}
          rightHandLinks={[{ link: '/projects', label: 'Back to All Projects' }]}
        />

        {children}
      </>
    );
  }
}


ProjectLayout.propTypes = {
  stringKey: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};

export default ProjectLayout;
