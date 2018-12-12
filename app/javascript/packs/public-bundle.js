import ReactOnRails from 'react-on-rails';

import ReferenceSearchContainer from '../bundles/AdvancedReferenceSearch/components/ReferenceSearchContainer';
import ReferenceSearch from '../bundles/AdvancedReferenceSearch/components/ReferenceSearch';
import SelectedReferenceSearch from '../bundles/AdvancedReferenceSearch/components/SelectedReferenceSearch';
import ItemTypesReferenceSearch from '../bundles/AdvancedReferenceSearch/components/ItemTypesReferenceSearch';
import DateTimeSearch from '../bundles/AdvancedDateTimeSearch/components/DateTimeSearch';
import DateTimeInput from '../bundles/DateTimeInput/components/DateTimeInput';
import ChoiceSetSearchContainer from '../bundles/AdvancedChoiceSetSearch/components/ChoiceSetSearchContainer';
import ChoiceSetSearch from '../bundles/AdvancedChoiceSetSearch/components/ChoiceSetSearch';

import ImageViewer from '../bundles/ImageViewer/components/ImageViewer';
import GeoViewer from '../bundles/GeoViewer/components/GeoViewer';

ReactOnRails.register({
  ReferenceSearchContainer, ReferenceSearch, SelectedReferenceSearch, ItemTypesReferenceSearch,
  DateTimeSearch, DateTimeInput,
  ChoiceSetSearchContainer, ChoiceSetSearch,
  ImageViewer,
  GeoViewer
});
