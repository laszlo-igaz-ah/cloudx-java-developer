package com.chtrembl.petstore.pet.service;

import com.chtrembl.petstore.pet.entity.PetEntity;
import com.chtrembl.petstore.pet.mapper.PetMapper;
import com.chtrembl.petstore.pet.model.Pet;
import com.chtrembl.petstore.pet.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@RequiredArgsConstructor
public class PetService {

    private final PetRepository petRepository;

    @Transactional(readOnly = true)
    public List<Pet> findPetsByStatus(List<String> status) {
        log.info("Finding pets with status: {}", status);

        List<PetEntity> entities = petRepository.findByStatus(status);
        return PetMapper.toModelList(entities);
    }

    @Transactional(readOnly = true)
    public Optional<Pet> findPetById(Long petId) {
        log.info("Finding pet with id: {}", petId);

        Optional<PetEntity> entity = petRepository.findById(petId);
        return entity.map(PetMapper::toModel);
    }

    @Transactional(readOnly = true)
    public List<Pet> getAllPets() {
        log.info("Getting all pets");
        List<PetEntity> entities = petRepository.findAll();
        return PetMapper.toModelList(entities);
    }

    @Transactional(readOnly = true)
    public int getPetCount() {
        return (int) petRepository.count();
    }
}