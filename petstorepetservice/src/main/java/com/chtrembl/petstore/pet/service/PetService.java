package com.chtrembl.petstore.pet.service;

import com.chtrembl.petstore.pet.entity.PetEntity;
import com.chtrembl.petstore.pet.mapper.PetMapper;
import com.chtrembl.petstore.pet.model.Pet;
import com.chtrembl.petstore.pet.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.StreamSupport;

@Service
@Slf4j
@RequiredArgsConstructor
public class PetService {

    private final PetRepository petRepository;

    public List<Pet> findPetsByStatus(List<String> status) {
        log.info("Finding pets with status: {}", status);

        List<PetEntity> entities = petRepository.findByStatusIn(status);
        return PetMapper.toModelList(entities);
    }

    public Optional<Pet> findPetById(String petId) {
        log.info("Finding pet with id: {}", petId);

        Optional<PetEntity> entity = petRepository.findById(petId);
        return entity.map(PetMapper::toModel);
    }

    public List<Pet> getAllPets() {
        log.info("Getting all pets");
        List<PetEntity> entities = StreamSupport.stream(petRepository.findAll().spliterator(), false).toList();
        return PetMapper.toModelList(entities);
    }

    public int getPetCount() {
        return (int) petRepository.count();
    }
}