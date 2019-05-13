import React, { Component } from 'react';
import producer from 'immer';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

class ProjectLayout extends Component {
  state = {
    project: {
      displayLabel: '',
    },
  }

  componentDidMount = () => {
    hyacinthApi.get(`/projects/${this.props.stringKey}`)
      .then((res) => {
        this.setState(producer((draft) => {
          draft.project.displayLabel = res.data.project.displayLabel;
        }));
      });
  }


  render() {
    return (
      <>
        <ContextualNavbar
          title={`Project | ${this.state.project.displayLabel}`}
          rightHandLinks={[{ link: '/projects', label: 'Back to All Projects' }]}
        />

        {this.props.children}
      </>
    );
  }
}

export default ProjectLayout;
