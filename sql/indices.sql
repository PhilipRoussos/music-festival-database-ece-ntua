-- Indices for queries --
CREATE INDEX idx_staff_specialty ON staff(specialty);
CREATE INDEX idx_subgenre_genre_id ON subgenre(genre_id);
CREATE INDEX idx_band_artist_band_id ON band_artist(band_id);
CREATE INDEX idx_festival_event_date ON festival_event(event_date);
CREATE INDEX idx_performance_event_id ON performance(event_id);
CREATE INDEX idx_festival_location_id ON festival(location_id);
CREATE INDEX idx_staff_event_staff_id ON staff_event(staff_id);
CREATE INDEX idx_artist_subgenre_artist_id ON artist_subgenre(artist_id);
CREATE INDEX idx_festival_event_festival_year ON festival_event(festival_year);

--CREATE INDEX idx_ticket_event_purchase ON ticket (event_id, purchase_method);
--CREATE INDEX idx_perf_type_event ON performance (performance_type, event_id);