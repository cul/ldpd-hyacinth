import React from 'react';
import { Link } from 'react-router-dom';
import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';

export default class DigitalObjectSearch extends React.Component {
  render() {
    return(
      <div>
        <ContextualNavbar
          title="Digital Objects"
          rightHandLinks={[{label: 'New Digital Object', link: '/digital-objects/new'}]} />

        <Link to="/digital-objects/1" className="nav-link" href="#">Object 1</Link>
        <Link to="/digital-objects/2" className="nav-link" href="#">Object 2</Link>
      </div>
    )
  }
  /*
  componentDidMount() {
    this.fetchSearchResults();
  }

  fetchSearchResults(nextProps) {
    fetch("/api/v1/digital_objects/search.json", {
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(this.state.searchParams),
    }).then(
      res => res.json()
    ).then(
      (response) => {
        this.setState(
          Object.assign({}, nextProps, {
            loading: false,
            searchResults: response.results
          })
        );
      },
      // Note: it's important to handle errors here
      // instead of a catch() block so that we don't swallow
      // exceptions from actual bugs in components.
      (error) => {
        console.log(error);
      }
    )
  }
  */
}
