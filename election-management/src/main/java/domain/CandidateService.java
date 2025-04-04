package domain;

import jakarta.enterprise.context.ApplicationScoped;

import java.util.List;

@ApplicationScoped
public class CandidateService {
    private final CandidateRepository repository;

    public CandidateService(CandidateRepository repository) {
        this.repository = repository;
    }

    public void save(Candidate candidate) {
        repository.save(candidate);

    }

    public List<Candidate> findAll() {
       return repository.findAll();
    }
}
