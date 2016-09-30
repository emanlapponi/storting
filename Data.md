# Notes on the variables
| Variable name                       | Variable description                                                                                         |
|:------------------------------------|:-------------------------------------------------------------------------------------------------------------|
| id                                  | unique id for a speech                                                                                       |
| url_rep_id                          | unique id for representatives in online urls (NA for presidents)                                             |
| rep_id                              | unique id for representatives from API (NA for presidents)                                                   |
| rep_first_name                      | first name                                                                                                   |
| rep_last_name                       | last name                                                                                                    |
| rep_name                            | full name                                                                                                    |
| rep_from                            | start of the mandate (NA for presidents)                                                                     |
| rep_to                              | end of mandate (NA for presidents)                                                                           |
| rep_type                            | type of representative (representant, vararepresentant), NA for all non representatives or elected ministers |
| county                              | county of provenance                                                                                         |
| list_number                         | position on the party list at the last election                                                              |
| party_id                            | unique id for a party                                                                                        |
| party_name                          | full name of the party                                                                                       |
| party_role                          | parliament role of the party (cabinet, opposition, support), NA for presidents                               |
| party_seats                         | number of seats in parliament for the speaker's party                                                        |
| cabinet_short                       | pet name for the current cabinet (also usable as an id)                                                      |
| cabinet_start                       | start date of the cabinet                                                                                    |
| cabinet_end                         | end date of the cabinet                                                                                      |
| cabinet_composition                 | composition of the cabinet (Coalition, Single-party)                                                         |
| rep_gender                          | gender                                                                                                       |
| rep_birth                           | date of birth                                                                                                |
| rep_death                           | date of death                                                                                                |
| parl_period                         | election cycle                                                                                               |
| parl_size                           | total amount of seats in parliament                                                                          |
| party_seats_lagting                 | party seats in the upper chamber (when applicable)                                                           |
| party_seats_odelsting               | party seats in the lower chamber (when applicable)                                                           |
| com_member                          | the committees the representative was a member of this parliamentary period                                  |
| com_date                            | the dates that the representative was member of the committees of `com_member`                               |
| com_role                            | the role the representative had in the corresponding committee to `com_member`                               |
| case_id                             | the id of the case                                                                                           |
| debate_reference                    | where to find the debate                                                                                     |
| debate_title                        | title of the debate                                                                                          |
| debate_subject                      | subject of the debate                                                                                        |
| debate_type                         | type of debate (question/interpellation etc)                                                                 |
| proposition_id                      | id of proposition                                                                                            |
| proposition_text                    | proposition text                                                                                             |
| document_group                      | underlying debate document group (proposisjon/melding etc)                                                   |
| document_subject_short              | short subject description of document                                                                        |
| decision_short                      | short description of decision made on the case under debate                                                  |
| document_note                       | any notes attached to the underlying document of debate                                                      |
| case_source_id                      | source id for the case                                                                                       |
| case_chair_id                       | representative id for the chair of the case                                                                  |
| case_type                           | type of case                                                                                                 |
| decision_text                       | description of decision on the case                                                                          |
| question_number                     | for questions, the question number                                                                           |
| question_from_id                    | for questions, who asked the question (rep_id)                                                               |
| question_to_id                      | for questions, who the question was asked to (rep_id)                                                        |
| question_answered_by_id             | for questions, who answered the question (rep_id)                                                            |
| question_answered_by_ministry_id    | for questions, the ministry the answering minister is under (id)                                             |
| question_answered_by_minister_title | for questions, the ministry the answering minister is under (title)                                          |
| subject_ids                         | id of the subjects under debate                                                                              |
| subject_names                       | names of the subjects under debate                                                                           |
| is_main_subject                     | is this the main subject?                                                                                    |
| main_subject_id                     | id of the main subject                                                                                       |
| subject_committee_id                | committee for this subject (id)                                                                              |
| subject_committee_name              | committee for this subject (name)                                                                            |
| agenda_case_number                  | the debates number on this day's agenda                                                                      |
| agenda_case_reference               | reference to the case (from agenda data)                                                                     |
| agenda_case_text                    | text for the case (from agenda data)                                                                         |
| agenda_case_type                    | type of case (from agenda data)                                                                              |
| agenda_number                       | the agenda number of this meeting                                                                            |
| meeting_id                          | meeting id (to match meeting data from API)                                                                  |
| procedure_id                        | all procedures the debate has gone through (id)                                                              |
| procedure_name                      | all procedures the debate has gone through (name)                                                            |
| procedure_stepnumber                | all procedures the debate has gone through (step number)                                                     |
| publication_export_id               | publication export id for underlying case                                                                    |
| publication_link_text               | publication text for underlying case                                                                         |
| publication_link_url                | publication url for underlying case                                                                          |
| publication_type                    | publication type for underlying case                                                                         |
| publication_undertype               | publication under type for underlying case                                                                   |
| related_case_id                     | id of related cases                                                                                          |
| related_case_type                   | type of related cases                                                                                        |
| related_case_title_short            | short titles of related cases                                                                                |
| keyword                             | One word keyword for debate                                                                                  |
| keywords                            | All keywords for debate                                                                                      |
| transcript                          | a date variable that distiguish day and night meetings                                                       |
| order                               | speech order in a given day                                                                                  |
| session                             | parliament session                                                                                           |
| time                                | timestamp of the speech                                                                                      |
| date                                | date of the speech                                                                                           |
| title                               | title (representative, president, minister etc)                                                              |
| text                                | the speech                                                                                                   |
